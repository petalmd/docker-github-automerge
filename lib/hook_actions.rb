require 'json'
require 'slack-notifier'

require 'client/provider'

class HookActions

  attr_accessor :logger

  def initialize(json, user, token, host)
    @logger = false
    @data = json
    @repo_name =  json['repository']['full_name']
    @provider = Client::Provider.new @repo_name, user, token, host
    @notifier = ENV['SLACK_WEBHOOK_URL'].nil? ? false : Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
  end

  def default_slack_message(from, to, url)
    {
      fallback: "#{from} to #{to}. #{@repo_name}",
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
          value: @repo_name,
          short: true
        },
        {
          title: 'URL',
          value: url,
          short: true
        }
      ]
    }
  end

  def notify(text, message_body, color)
    @notifier.ping text, attachments: [message_body.merge(color: color)] if @notifier
  end

  def self.file_to_json(filename)
    file = File.new filename
    JSON.parse file.read
  end

end
