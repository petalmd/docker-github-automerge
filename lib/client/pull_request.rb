module Client
  class PullRequest

    def initialize(provider)
      @provider = provider
    end

    def list(status = 'open')
      @provider.get "/pulls?status=#{status}"
    end

    def get(pull_number)
      @provider.get "/pulls/#{pull_number}"
    end

    def latest_commit(pull_number)

    end

    def merge(pull_number)
      @provider.put "/pulls/#{pull_number}/merge"
    end

  end
end
