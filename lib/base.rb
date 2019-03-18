# frozen_string_literal: true

if RUBY_VERSION.to_f < 2.3
  puts(
    "WARNING: #{RUBY_VERSION} is not tested. "\
    'There might be issues with it using version older then 2.3'
  )
end
# This load order is important, Remeber changing the order could effect the code
require File.expand_path('gem_installer', __dir__).to_s
require File.expand_path('the_movie_db_config', __dir__).to_s
require File.expand_path('config', __dir__).to_s
require File.expand_path('logger', __dir__).to_s
require File.expand_path('shell', __dir__).to_s

GemInstaller.require_gems

require 'fileutils'
require 'pathname'
require 'optparse'
require 'open3'
require 'timeout'
require 'shellwords'

Dir[
  File.expand_path('ripper/helpers/', __dir__) + '/*.rb'
].each do |helpers|
  require helpers
end
Dir[
  File.expand_path('ripper/', __dir__) + '/*.rb'
].each do |lib|
  require lib
end
Dir[
  File.expand_path('ripper/model/', __dir__) + '/*.rb'
].each do |model|
  require model
end
Dir[
  File.expand_path('ripper/the_movie_db/', __dir__) + '/*.rb'
].each do |model|
  require model
end

require File.expand_path('ripper/create_mkv/base', __dir__)
require File.expand_path('ripper/create_mkv/movie', __dir__)
require File.expand_path('ripper/create_mkv/tv', __dir__)

require 'set'
require 'net/http'
require 'uri'
require 'net/scp'
require 'json'
