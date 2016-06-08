require 'faraday'

module Client
  class Provider

    attr_reader :base_url, :repo_name
    attr_writer :connection

    def initialize(repo_name, user, token, host)
      @connection = Faraday.new(host) do |faraday|
        faraday.request  :url_encoded
        faraday.headers['Accept'] = 'application/vnd.github.v3+json'
        faraday.headers['Content-Type'] = 'application/json'
        faraday.basic_auth user, token
        faraday.adapter  Faraday.default_adapter
      end

      @repo_name = repo_name
      @base_url = "/repos/#{repo_name}"
    end

    def get(endpoint)
      req = @connection.get "#{@base_url}#{endpoint}"
      JSON.parse req.body
    end

    def put(endpoint, payload = {})
      req = @connection.put "#{@base_url}#{endpoint}", payload.to_json
      JSON.parse req.body
    end

  end
end
