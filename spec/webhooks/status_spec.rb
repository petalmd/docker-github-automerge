require 'json'
require 'webhooks/status'

describe Webhooks::Status do

  context 'when we receive a status webhook' do

    it 'should parse the associated repo' do
      s = Webhooks::Status.new '{}'
      s.test
      # Webhooks::Status.new '{asdf}'
    end
  end
end