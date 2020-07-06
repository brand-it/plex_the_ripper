# frozen_string_literal: true
# # frozen_string_literal: true
# APP_ROOT = File.expand_path('../', __dir__)

# if RUBY_VERSION.to_f < 2.3
#   puts(
#     "WARNING: #{RUBY_VERSION} is not tested. "\
#     'There might be issues with it using version older then 2.3'
#   )
# end
# # This load order is important, Remeber changing the order could effect the code
# require 'fileutils' # required for GemInstaller
# require File.expand_path('gem_installer', __dir__).to_s
# require File.expand_path('the_movie_db_config', __dir__).to_s
# require File.expand_path('config', __dir__).to_s
# require File.expand_path('logger', __dir__).to_s
# require File.expand_path('shell', __dir__).to_s

# begin
#   require 'bundler'
#   Bundler.require
# rescue StandardError => exception
#   Logger.error('Issue loading gems using bundler')
#   Logger.error("Solutions: ")
#   Logger.error("  run `gem update --system`")
#   Logger.error("  run `gem install bundle:2.0.1`")
#   Logger.error("  run `bundle install`")
#   raise exception
# end

# require 'pathname'
# require 'optparse'
# require 'open3'
# require 'timeout'
# require 'shellwords'

# Dir[
#   File.expand_path('ripper/helpers/', __dir__) + '/*.rb'
# ].each do |helpers|
#   require helpers
# end
# Dir[
#   File.expand_path('ripper/', __dir__) + '/*.rb'
# ].each do |lib|
#   require lib
# end
# Dir[
#   File.expand_path('ripper/model/', __dir__) + '/*.rb'
# ].each do |model|
#   require model
# end
# Dir[
#   File.expand_path('ripper/the_movie_db/', __dir__) + '/*.rb'
# ].each do |model|
#   require model
# end

# require File.expand_path('ripper/create_mkv/progressable', __dir__)
# require File.expand_path('ripper/create_mkv/make_backup', __dir__)
# require File.expand_path('ripper/create_mkv/base', __dir__)
# require File.expand_path('ripper/create_mkv/movie', __dir__)
# require File.expand_path('ripper/create_mkv/tv', __dir__)

# require 'set'
# require 'net/http'
# require 'uri'
# require 'net/scp'
# require 'json'

# Dir[
#   File.expand_path('ripper/download_tools/', __dir__) + '/*.rb'
# ].each do |model|
#   require model
# end
