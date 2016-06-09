require 'faraday'

module Client
  class Provider

    class UnauthorizedError < StandardError; end
    class NotFoundError < StandardError; end

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
      verify_response req
      JSON.parse req.body
    end

    def put(endpoint, payload = {})
      req = @connection.put "#{@base_url}#{endpoint}", payload.to_json
      verify_response req
      JSON.parse req.body
    end

    private
    def verify_response(req)
      raise UnauthorizedError, req.body if req.status == 401
      raise NotFoundError, req.body if req.status == 404
    end

  end
end
