# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'cable_ready', '>= 4.3'
gem 'concurrent-ruby', require: 'concurrent'
gem 'dotiw'
gem 'dry-initializer'
gem 'dry-struct'
gem 'dry-types'
gem 'faraday'
gem 'hotwire-rails'
gem 'jbuilder', '>= 2.7'
gem 'kaminari', '>= 1.2.1'
gem 'os', '>= 1.1'
gem 'puma', '>= 4.1'
gem 'rails', '~> 6.1.4'
gem 'rainbow'
gem 'sass-rails', '>= 6'
gem 'simple_form'
gem 'sqlite3', '>= 1.4'
gem 'sys-filesystem', '~> 1.4'
gem 'text', '~> 1.3', '>= 1.3.1'
gem 'view_component', '>= 2.18'
gem 'webpacker', '>= 5.0'
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
  gem 'rubocop-discourse'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'super_diff'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'database_cleaner-active_record'

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'

  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
