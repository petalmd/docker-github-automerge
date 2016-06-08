require 'client/provider'
require 'client/pull_request'
require 'client/status'
require 'webhooks/status'
require 'json'

class AutoMerge

  def initialize(json, user, token, host = 'https://api.github.com/')
    @status = Webhooks::Status.new json
    repo_name =  @status.repository['full_name']
    @provider = Client::Provider.new repo_name, user, token, host
    configure_endpoints
  end

  def configure_endpoints
    @pr_api = Client::PullRequest.new @provider
    @status_api = Client::Status.new @provider
  end

  def list(mergeable_only = true)
    pull_requests = @pr_api.list.collect {|pr| @pr_api.get pr['number']}
    pull_requests.select do |pull_request|
      sha = pull_request['head']['sha']
      branch_status = @status_api.get sha

      can_merge = pull_request['mergeable'] && branch_status['state'] == 'success'
      mergeable_only ? can_merge : pull_request
    end
  end

  def self.file_to_json(filename)
    file = File.new filename
    JSON.parse file.read
  end

end
