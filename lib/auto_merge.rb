require 'client/provider'
require 'client/pull_request'
require 'client/status'
require 'webhooks/status'

require 'json'
require 'slack-notifier'

class AutoMerge

  ENV['SLACK_URL']

  attr_accessor :logger

  def initialize(json, user, token, host = 'https://api.github.com/')
    @logger = false
    @status = Webhooks::Status.new json
    repo_name =  @status.repository['full_name']
    @provider = Client::Provider.new repo_name, user, token, host

    @notifier = ENV['SLACK_WEBHOOK_URL'].nil? ? false : Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
    configure_endpoints
  end

  def configure_endpoints
    @pr_api = Client::PullRequest.new @provider
    @status_api = Client::Status.new @provider
  end

  def perform
    pull_requests = @pr_api.list.collect {|pr| @pr_api.get pr['number']}
    pull_requests.select do |pull_request|
      sha = pull_request['head']['sha']
      branch_status = @status_api.get sha

      can_merge = pull_request['mergeable'] && branch_status['state'] == 'success'
      if can_merge
        from = pull_request['head']['label']
        to = pull_request['base']['label']
        url = pull_request['html_url']
        merge pull_request['number'], sha, from, to, url
      else
        @logger.info "Skipping PR ##{pull_request['number']} in #{@status.repository['full_name']} - not ready to merge" if @logger
      end
    end
  end

  def merge(number, sha, from, to, url)
    status, body = @pr_api.merge number, sha

    merge_msg = {
        fallback: "#{from} to #{to}. #{@status.repository['full_name']}",
        text: body['message'],
        fields: [
            {
              title: 'Branch',
              value: from,
              short: true
            },
            {
                title: 'Target Branch',
                value: to,
                short: true
            },
            {
                title: 'Repository',
                value: @status.repository['full_name'],
                short: true
            },
            {
                title: 'URL',
                value: url,
                short: true
            }
        ]
    }

    case status
      when 200, 201
        text = 'Successful merge'
        color = 'good'

      when 409
        text = 'Merge conflicts'
        color = 'warning'
      else
        text = 'Couldnt merge branch - see on GitHub'
        color = 'danger'
    end

    @logger.info "Merged\n#{merge_msg}" if @logger
    @notifier.ping text, attachments: [merge_msg.merge(color: color)] if @notifier
  end

  def self.file_to_json(filename)
    file = File.new filename
    JSON.parse file.read
  end

end
