# frozen_string_literal: true

# Configuration Information for the ripper application
class TheMovieDBConfig
  attr_accessor :selected_video
  attr_reader :api_key

  def invalid_api_key?
    !valid_api_key?
  end

  def valid_api_key?
    TheMovieDB::Movie.request('movie/550') do |response|
      Logger.debug(response.body)
      response.is_a?(Net::HTTPSuccess)
    end
  end

  def api_key=(value)
    @valid = nil
    return if value.to_s == ''

    @api_key = value
    if invalid_api_key?
      Logger.warning("The Movie DB API key is invalid #{@api_key}")
      @api_key = nil
    end
  end
end
