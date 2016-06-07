# Parses a commit status webhook from GitHub and updates Pull Requests to auto-merge
require 'json'
require 'faraday'

if ARGV.count != 3
  puts "---------------"
  puts "run with <executable> $GITHUB_HOST $GITHUB_USER $GITHUB_OAUTH_TOKEN json"
  puts "---------------"
  exit -1
end

endpoint = Faraday.new "https://#{ARGV[0]}/api/v3/"
puts endpoint
endpoint.headers['Accept'] = "application/vnd.github.v3+json"
ARGV[1]

webhook = JSON.parse ARGV[2]
puts "Received webhook with #{webhook.count} events"
webhook.select {|hook| hook['object_kind'] == 'merge_request'}.each do |mr|
  id = mr['object_attributes']['id']
  project_id = mr['object_attributes']['source_project_id']
  puts "Processing Merge Request #{id}"
  puts "   Project ##{project_id}"

  req = endpoint.put do |r|
    r.url "projects/#{project_id}/merge_requests/#{id}/merge"
    r.headers['Content-Type'] = 'application/json'
    r.body = "{'should_remove_source_branch': 'true', 'merged_when_build_succeeds': true}"
  end
  puts "Done Processing Merge Request #{id}, result #{req.status}"
  raise StandardError, "Request failed, couldnt update ##{id}" unless req.status == 200
end
