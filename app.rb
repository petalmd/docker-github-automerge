require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bundler/setup'

require 'slack-notifier'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib|
  require File.basename(lib, '.*')
}

set :port, ENV['PORT'] || 8080
set :user, ENV['USER']
set :token, ENV['TOKEN']
set :host, ENV['HOST'] || 'https://api.github.com'


raise ArgumentError, 'Missing user and token environment variables' unless settings.user && settings.token && settings.host

post '/webhooks' do
  body = request.body.read
  begin
    json = JSON.parse body

    auto = AutoMerge.new json, settings.user, settings.token, settings.host
    auto.logger = logger
    auto.perform

    'success'
  rescue Exception => e
    if ENV['SLACK_WEBHOOK_URL']
      notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
      error = {
          fallback: 'AutoMerge server had an error while receiving webhook',
          text: 'AutoMerge server had an error while receiving webhook',
          color: 'danger'
      }
      notifier.ping 'AutoMerge', attachments: [error]
    end
    raise e
  end
end
