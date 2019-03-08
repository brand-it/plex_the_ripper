# Configuration Information for the ripper application
class TheMovieDBConfig
  attr_accessor :selected_video
  attr_reader :api_key

  def request(path, params: {})
    uri = URI("https://api.themoviedb.org/3/#{path}")
    uri.query = URI.encode_www_form(params.merge(api_key: api_key))
    response = Net::HTTP.get_response(uri)
    if block_given?
      yield(response)
    elsif response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end

  def invalid_api_key?
    !valid_api_key?
  end

  def valid_api_key?
    return @valid_api_key if @valid_api_key

    @valid = request('movie/550') do |response|
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
