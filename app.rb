require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bundler/setup'

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
  json = JSON.parse body

  auto = AutoMerge.new json, settings.user, settings.token, settings.host
  auto.logger = logger
  auto.perform

  'success'
end
