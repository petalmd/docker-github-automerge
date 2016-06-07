module Webhooks
  class Status

    attr_reader :payload
    
    def initialize(filename)
      file = File.new filename
      @payload = JSON.parse file.read
      raise ArgumentError, 'File content is expected to be a json' unless @payload.is_a? Hash
      parse
    end

    def parse
      @repository = @payload['repository']
      @repository = @payload['repository']
    end
  end
end
