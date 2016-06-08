module Webhooks
  class Status

    attr_reader :payload, :repository

    def initialize(json)
      raise ArgumentError, 'File content is expected to be a json' unless json.is_a? Hash
      parse json
    end

    def parse(json)
      @payload = json
      @repository = @payload['repository']
    end
  end
end
