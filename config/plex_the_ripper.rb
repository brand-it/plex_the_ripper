# frozen_string_literal: true

require 'active_support'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/object/blank'

module PlexTheRipper
  class Error < StandardError; end

  class Config
    def database
      @database ||= YAML.safe_load(ERB.new(File.read('config/database.yml')).result)
    end
  end
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['RAILS_ENV'].presence || ENV['RACK_ENV'].presence || 'development')
    end

    def root
      @root ||= Pathname.new(File.expand_path('../', __dir__))
    end

    def config
      @config ||= Config.new
    end

    def redis_url
      ENV['REDIS_URL'].presence
    end
  end
end
