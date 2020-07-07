# frozen_string_literal: true

module Ripper
  class << self
    def root
      @root ||= File.expand_path('../', __dir__)
    end

    def logger
      @logger ||= Logger.new(root + '/Applicationlog')
    end
  end
end
