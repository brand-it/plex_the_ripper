# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bootsnap', require: false
gem 'cable_ready'
gem 'dotiw'
gem 'dry-initializer'
gem 'dry-struct'
gem 'dry-types'
gem 'faraday'
gem 'hotwire-rails'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'kaminari'
gem 'net-ftp'
gem "net-pop", require: false
gem 'os'
gem 'progressbar'
gem 'puma'
gem 'rails'
gem 'rainbow'
gem 'sass-rails'
gem 'simple_form'
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.6' # https://github.com/sparklemotion/sqlite3-ruby/issues/529
gem 'stimulus-rails'
gem 'sys-filesystem'
gem 'text'
gem 'view_component'
gem 'wisper'
gem 'workflow'

group :development, :test do
  gem 'annotate'
  gem 'awesome_print'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
  gem 'rspec-github', require: false
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-discourse'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'shoulda-matchers'
  gem 'super_diff'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'

  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
