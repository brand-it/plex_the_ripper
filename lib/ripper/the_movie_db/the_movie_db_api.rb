# frozen_string_literal: true

module TheMovieDBAPI
  def config
    return @config if @config

    @config = Config.configuration.the_movie_db_config
    return @config if @config.is_a?(TheMovieDBConfig)

    raise(
      Plex::Ripper::Abort,
      'The Movie DB Config should not be nil but some how it is. Create a issue in github please'
    )
  end

  def request(path, params: {})
    return if config.api_key.nil?

    uri = URI("https://api.themoviedb.org/3/#{path}")
    uri.query = URI.encode_www_form(params.merge(api_key: config.api_key))
    response = Net::HTTP.get_response(uri)
    if block_given?
      yield(response)
    elsif response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end

  def search(page: 1, query:, type:)
    results = []
    more_pages = true
    while more_pages
      response = request(
        "search/#{type}", params: { query: query, page: page }
      )
      if response
        more_pages = page < response['total_pages']
        results += response['results']
      else
        more_pages = false
      end
      page += 1

    end
    results
  end

  # This build a bunch of uniq names that can be used to build the names of the files.
  # These uniq names work best as they play nice with the Plex data and plus then you can
  # tell if you have which movie is from 1999 and 2032.
  # Example:
  #   uniq_names(search('dark'))
  #
  def uniq_names(search_results)
    names_hash = Hash.new(0)
    search_results.map do |result|
      names_hash[result.name] += 1
      if names_hash[result.name] > 1
        extra_info = if result.first_air_date != ''
                       Time.parse(result.first_air_date).year
                     else
                       result.id
                     end
        "#{result.name} (#{extra_info})"
      else
        result.name
      end
    end
  end

  def video(type:, id:)
    request("#{type}/#{id}")
  end
end
