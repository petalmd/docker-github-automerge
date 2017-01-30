require 'client/pull_request'
require 'client/status'
require 'hook_actions'

class AutoMerge < HookActions

  def initialize(json, user, token, host)
    super json, user, token, host
    configure_endpoints
  end

  def configure_endpoints
    @pr_api = Client::PullRequest.new @provider
    @status_api = Client::Status.new @provider
  end

  def perform
    impacted_branches = @data['branches'].collect {|branch| branch['name']}

    pull_requests = impacted_branches.collect do |branch_name|
      @pr_api.list(branch_name).collect {|pr| @pr_api.get pr['number']}
    end.flatten

    pull_requests.select do |pull_request|
      sha = pull_request['head']['sha']

      can_merge = pull_request['mergeable'] && pull_request['mergeable_state'] == 'clean'
      if can_merge
        from = pull_request['head']['label']
        to = pull_request['base']['label']
        url = pull_request['html_url']
        merge pull_request['number'], sha, from, to, url
      else
        @logger.info "Skipping PR ##{pull_request['number']} in #{@repo_name} - not ready to merge" if @logger
      end
    end
  end

  def merge(number, sha, from, to, url)
    status, body = @pr_api.merge number, sha
    merge_msg = default_slack_message body['message'], from, to, url
    @logger.info "Attempted to merge\n#{merge_msg} status #{status}" if @logger

    case status
      when 200, 201
        # Only notify when there's an error. The Pull Request webhook will take care of notifying on success
      when 409
        text = 'Merge conflicts'
        color = 'warning'
        notify text, merge_msg, color
      else
        text = "Couldnt merge branch - see on GitHub status code: #{status}"
        color = 'warning'
        notify text, merge_msg, color
    end
  end

end
