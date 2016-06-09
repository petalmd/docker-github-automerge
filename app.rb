require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bundler/setup'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib|
  require File.basename(lib, '.*')
}

set :port, ENV['port'] || 8080
set :user, ENV['user']
set :token, ENV['token']
set :host, ENV['host'] || 'https://api.github.com'


raise ArgumentError, 'Missing user and token environment variables' unless settings.user && settings.token && settings.host

post '/webhooks' do
  body = request.body.read
  json = JSON.parse body

  auto = AutoMerge.new json, settings.user, settings.token, settings.host
  puts auto.list

  'success'
end
