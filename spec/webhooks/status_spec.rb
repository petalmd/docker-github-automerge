require 'json'
require 'webhooks/status'

describe Webhooks::Status do

  let!(:payload) {
    File.new('spec/fixtures/status_webhook.txt').readlines
  }

  context 'when we receive a status webhook' do

    it 'should parse the associated repo' do
      s = Webhooks::Status.new '{}'
      puts payload
      # Webhooks::Status.new '{asdf}'
    end
  end
end