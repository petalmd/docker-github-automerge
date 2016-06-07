require 'json'
require 'webhooks/status'
require 'client/status'
require 'client/pull_request'
require 'client/provider'

describe Webhooks::Status do

  let(:stub_file) {
    'spec/fixtures/status_webhook.txt'
  }

  context 'when we receive a status webhook' do

    it 'should parse the associated repo' do
      status = Webhooks::Status.new stub_file
      repo_name = status.repository['full_name']
      provider = Client::Provider.new repo_name, 'xxxx', 'xxxx'
      pull_requests = JSON.parse Client::PullRequest.new(provider).list.body
      statuses = Client::Status.new(provider)
      pull_requests.each do |pr|
        head = pr['head']
        branch_status = JSON.parse statuses.get(head['sha']).body
        if branch_status['state'] == 'success'
          pr.merge
        else
          puts 'not ready to merge'
        end
      end
    end
  end
end
