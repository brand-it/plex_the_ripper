# frozen_string_literal: true

# Configuration Information for the ripper application
class TheMovieDBConfig
  attr_accessor :selected_video
  attr_reader :api_key

  def invalid_api_key?
    !valid_api_key?
  end

  def valid_api_key?
    return @valid_api_key if @valid_api_key

    @valid_api_key = TheMovieDB::Movie.request('authentication/session/new') do |response|
      response.is_a?(Net::HTTPSuccess)
    end
  end

  def api_key=(value)
    @valid = nil
    return if value.to_s == ''

    @api_key = value

    @api_key = nil if invalid_api_key?
  end
end
