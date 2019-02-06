# This load order is important, Remeber changing the order could effect the code
require 'fileutils'
require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

ENV['GEM_HOME'] = File.expand_path('gems', __dir__).to_s
FileUtils.mkdir_p(ENV['GEM_HOME'])
ENV['GEM_PATH'] = "#{ENV['GEM_HOME']}:/var/lib/ruby/gems/1.8"
Gem.clear_paths

GemInstaller.install 'nokogiri'
GemInstaller.install 'net-scp'
GemInstaller.install 'ruby-progressbar'

require File.expand_path('ripper/helpers/gem_installer', __dir__).to_s
require File.expand_path('ripper/helpers/time_helper', __dir__).to_s
require File.expand_path('ripper/helpers/bash_helper', __dir__).to_s
require File.expand_path('ripper/helpers/humanizer_helper', __dir__).to_s
require File.expand_path('ripper/helpers/tv_shows_cleaner', __dir__).to_s

require File.expand_path('ripper/movies', __dir__).to_s
require File.expand_path('ripper/config', __dir__).to_s
require File.expand_path('ripper/disc_info', __dir__).to_s
require File.expand_path('ripper/make_mkv', __dir__).to_s
require File.expand_path('ripper/opt_parser', __dir__).to_s
require File.expand_path('ripper/uploader', __dir__).to_s
require File.expand_path('ripper/logger', __dir__).to_s
require File.expand_path('ripper/notification', __dir__).to_s
require File.expand_path('ripper/ask_for_tv_details', __dir__).to_s
require File.expand_path('ripper/ask_for_movie_details', __dir__).to_s
require File.expand_path('ripper/file_checker', __dir__).to_s

require 'nokogiri'
require 'set'
require 'net/http'
require 'uri'
require 'net/scp'
require 'json'
require 'ruby-progressbar'
