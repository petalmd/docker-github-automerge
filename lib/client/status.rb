module Client
  class Status

    def initialize(provider)
      @provider = provider
    end

    def get(sha)
      req = @provider.get "/commits/#{sha}/status"
      JSON.parse(req.body)
    end

  end
end