describe Client::Provider do

  context 'when we initialize a provider' do
    let(:repo_name) {'client/provider'}

    let(:user) {'smith'}
    let(:token) {'1234567890'}
    let(:host) {'http://google.com'}

    it 'instantiate the provider properly' do
      expect(Client::Provider.new repo_name, user, token, host).not_to be_nil
    end

    it 'configure the base_url properly' do
      provider = Client::Provider.new repo_name, user, token, host
      expect(provider.base_url).to eq "/repos/#{repo_name}"
    end

    context 'when making requests' do

      let(:stubs) {Faraday::Adapter::Test::Stubs.new}
      let(:faraday) {
        Faraday.new do |builder|
          builder.adapter :test, stubs
        end
      }

      it 'should prepend base_url when making get call' do
        provider = Client::Provider.new repo_name, user, token, host
        stubs.get("#{provider.base_url}/random") { |env| [ 200, {}, '{"result":"random"}' ]}

        provider.connection = faraday
        expect(provider.get '/random').to eq('result' => 'random')
      end

      it 'should prepend base_url when making put call' do
        provider = Client::Provider.new repo_name, user, token, host
        stubs.put("#{provider.base_url}/random") { |env| [ 200, {}, '{"result":"random"}' ]}

        provider.connection = faraday
        expect(provider.put '/random').to eq('result' => 'random')
      end

    end
  end

end
