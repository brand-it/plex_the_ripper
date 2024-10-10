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
require './lib/progress_tracker/base'

module PlexRipper
  VERSION = File.read(File.expand_path('./current_version.txt')).gsub('v', '').strip
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    config.active_record.sqlite3_production_warning = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |g|
      g.stylesheets false
    end
    config.faraday_logging = ENV['FARADAY_LOGGING'] == 'true'
    port = ENV['PORT']&.to_i
    port ||= ARGV.index('-p') ? ARGV[ARGV.index('-p').next].to_i : 3000
    routes.default_url_options = { host: 'localhost', port:  }
  end
end

Time::DATE_FORMATS[:usa_pretty] = '%-m/%-d/%y at %-l:%M%P'
