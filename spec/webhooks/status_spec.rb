describe Webhooks::Status do

  let(:stub_file) {
    'spec/fixtures/status_webhook.txt'
  }

  let(:json) {AutoMerge.file_to_json stub_file}

  context 'when we receive a status webhook' do

    let(:json) {AutoMerge.file_to_json stub_file}

    it 'should parse the input json and assign payload' do
      status = Webhooks::Status.new json
      expect(status.payload).not_to be_nil
      expect(status.repository).not_to be_nil
      expect(status.repository).to be_a Hash
    end

    it 'should raise an error when json is invalid' do
      expect{Webhooks::Status.new ''}.to raise_error(ArgumentError)
    end

    it 'should extract the repo name from the provided json' do
      expect(json['repository']['full_name']).to eq 'baxterthehacker/public-repo'
    end

  end
end
