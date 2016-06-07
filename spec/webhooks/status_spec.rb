require 'json'
require 'webhooks/status'

describe Webhooks::Status do

  let(:stub_file) {
    'spec/fixtures/status_webhook.txt'
  }

  context 'when we receive a status webhook' do

    it 'should parse the associated repo' do
      status = Webhooks::Status.new stub_file
      expect(status.payload.name).to eq ''
      # Webhooks::Status.new '{asdf}'
    end
  end
end