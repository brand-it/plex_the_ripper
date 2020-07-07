# frozen_string_literal: true
require_relative 'boot'

require File.expand_path('../application', __dir__)

Bundler.require(:default, Application.env)

Dir[Application.root.join('config', 'initializers', '*')].sort.each do |intializer|
  require intializer
end

module PlexTheRipper
  class Application < ::Application
    class Error < StandardError; end

  #  configure :production, :development do
  #     enable :logging
  #   end
  #   configure :development do
  #     use BetterErrors::Middleware
  #     BetterErrors.application_root = Application.root
  #   end
  end
end
