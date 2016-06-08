module Client
  class PullRequest

    def initialize(provider)
      @provider = provider
    end

    def list(status = 'open')
      @provider.get "/pulls?status=#{status}"
    end

    def get(pr_number)
      @provider.get "/pulls/#{pr_number}"
    end

    def merge(pr_number, sha)
      @provider.put "/pulls/#{pr_number}/merge", {sha: sha}
    end

  end
end
