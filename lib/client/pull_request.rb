module Client
  class PullRequest

    def initialize(provider)
      @provider = provider
    end

    def list(branch)
      req = @provider.get "/pulls?head=petalmd:#{branch}"
      JSON.parse(req.body)
    end

    def get(pr_number)
      req = @provider.get "/pulls/#{pr_number}"
      JSON.parse(req.body)
    end

    def merge(pr_number, sha)
      req = @provider.put "/pulls/#{pr_number}/merge", {sha: sha}
      [req.status, JSON.parse(req.body)]
    end

  end
end
