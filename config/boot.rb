# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

Dir[File.expand_path('./initializers/*', __dir__)].sort.each do |helpers|
  require helpers
end

Zeitwerk::Loader.new.tap do |loader|
  Dir[File.expand_path('../app/*', __dir__)].each do |dir|
    loader.push_dir(dir)
  end
  loader.push_dir(File.expand_path('../lib', __dir__))
  loader.setup
end
