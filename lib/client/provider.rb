require 'faraday'

module Client
  class Provider

    def initialize(repo_name, user, token, host = 'https://api.github.com/')
      @connection = Faraday.new(host) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end

      @repo_name = repo_name
      @base_url = "/repos/#{repo_name}"
    end

    def get(endpoint)
      @connection.get "#{@base_url}#{endpoint}"
    end

    def put(endpoint)
      @connection.put "#{@base_url}#{endpoint}"
    end

  end
end
