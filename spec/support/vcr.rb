# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.filter_sensitive_data('<API_KEY>') { Config::TheMovieDb.newest.first&.settings&.api_key }
end
