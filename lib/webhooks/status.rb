module Webhooks
  class Status
    
    def initialize(payload)
      @payload = JSON.parse payload
    end

  end
end
