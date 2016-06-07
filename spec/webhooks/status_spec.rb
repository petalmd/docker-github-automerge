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
      provider = Client::Provider.new repo_name, 'xxx', 'xxx'
      pr_api = Client::PullRequest.new provider
      status_api = Client::Status.new provider

      pull_requests = pr_api.list

      pull_requests.each do |pr|
        pr = pr_api.get(pr['number'])
        head = pr['head']
        branch_status = status_api.get head['sha']
        if pr['mergeable'] && branch_status['state'] == 'success'
          puts pr_api.merge pr['number'], head['sha']
          # TODO: report in slack
          # TODO: delete branch head['pr']
        else
          puts 'not ready to merge'
        end
      end
    end
  end
end
