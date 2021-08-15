# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.filter_sensitive_data('<API_KEY>') { Config::TheMovieDb.newest&.settings&.api_key }
  config.configure_rspec_metadata!
end
