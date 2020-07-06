# frozen_string_literal: true

require 'bundler/setup'
require_relative 'plex_the_ripper'

Bundler.require(:default, PlexTheRipper.env)
ActiveRecord::Base.configurations = PlexTheRipper.config.database
ActiveRecord::Base.establish_connection PlexTheRipper.env.to_sym
ActiveRecord::Base.connection_handlers = { writing: ActiveRecord::Base.default_connection_handler }
require_relative 'boot'
