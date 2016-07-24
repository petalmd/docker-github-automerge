require 'client/pull_request'
require 'hook_actions'
require 'net/http'

class MergeReport < HookActions

  def initialize(json, user, token, host)
    super json, user, token, host
    @pr_api = Client::PullRequest.new @provider
  end

  def perform
    action = @data['action']
    pull_request = @pr_api.get @data['pull_request']['number']

    if action == 'closed' && !pull_request['merged_at'].nil?
      from = pull_request['head']['ref']
      to = pull_request['base']['ref']
      url = pull_request['html_url']
      report pull_request['title'], from, to, url
      notify_selfpro @data['repository']['name'], from
    else
      @logger.info "Skipping reporting for PR ##{pull_request['number']} in #{@repo_name} - pull request still open" if @logger
    end
  end

  def report(title, from, to, url)
    text = "*#{title}* was merged"
    color = 'good'
    merge_msg = default_slack_message title, from, to, url

    @logger.info "Reporting status for merged PR \n#{merge_msg}" if @logger
    notify text, merge_msg, color
  end

  def notify_selfpro(repo, from)
    @logger.info "Reporting status to SelfPro" if @logger

    uri = URI.parse('http://selfpro.petalmd.com/hooks/branch:merge')
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    data = { 'project' => repo, 'branch' => from}
    req.body = data.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(req)
  end
end
