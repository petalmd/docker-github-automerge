require 'client/pull_request'
require 'hook_actions'

class MergeReport < HookActions

  def initialize(json, user, token, host)
    super json, user, token, host
    @pr_api = Client::PullRequest.new @provider
  end

  def perform
    action = @data['action']
    pull_request = @pr_api.get @data['pull_request']['number']

    if action == 'closed' && !pull_request['merged_at'].nil?
      from = pull_request['head']['label']
      to = pull_request['base']['label']
      url = pull_request['html_url']
      report pull_request['title'], from, to, url
    else
      @logger.info "Skipping reporting for PR ##{pull_request['number']} in #{@repo_name} - pull request still open" if @logger
    end
  end

  def report(title, from, to, url)
    text = "#{title} was merged"
    color = 'good'
    merge_msg = default_slack_message from, to, url

    @logger.info "Reporting status for merged PR \n#{merge_msg}" if @logger
    @notifier.notify text, merge_msg, color
  end
end
