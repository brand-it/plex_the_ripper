module Ripper
  class << self
    def root
      @root ||= File.expand_path('../', __dir__)
    end

    def logger
      @logger ||= Logger.new(root + '/app.log')
    end
  end
end
