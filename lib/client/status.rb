module Client
  class Status

    def initialize(provider)
      @provider = provider
    end

    def get(sha)
      @provider.get "/commits/#{sha}/status"
    end

  end
end