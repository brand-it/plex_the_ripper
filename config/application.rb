require_relative 'boot'

require "rails"

%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_cable/engine
  action_text/engine
  sprockets/railtie
).each do |railtie|
  require railtie
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'view_component/engine'
require 'sys/filesystem'

module PlexRipper
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |g|
      g.stylesheets false
    end
    config.faraday_logging = ENV['FARADAY_LOGGING'] == 'true'
  end
end

Time::DATE_FORMATS[:usa_pretty] = '%-m/%-d/%y at %-l:%M%P'
