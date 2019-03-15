# frozen_string_literal: true

# Configuration Information for the ripper application
class TheMovieDBConfig
  attr_writer :selected_video
  attr_reader :api_key

  def invalid_api_key?
    !valid_api_key?
  end

  def valid_api_key?
    return @valid_api_key if @valid_api_key

    @valid = TheMovieDB.new.request('movie/550') do |response|
      response.is_a?(Net::HTTPSuccess)
    end
  end

  def api_key=(value)
    @valid = nil
    return if value.to_s == ''

    @api_key = value

    @api_key = nil if invalid_api_key?
  end

  def selected_video
    return {} if @selected_video.nil?

    @selected_video
  end
end
