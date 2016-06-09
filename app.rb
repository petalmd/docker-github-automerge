require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bundler/setup'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib|
  require File.basename(lib, '.*')
}

set :port, 8080

post '/webhooks' do
  AutoMerge.new({}, 'user', 'token')
  'asdf'
end
