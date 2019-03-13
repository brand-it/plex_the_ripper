# frozen_string_literal: true

class TheMovieDB
  attr_reader :config

  def initialize
    @config = Config.configuration.the_movie_db_config
  end

  def request(path, params: {})
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
    results = request("search/#{type}", params: { query: query, page: page })
    return {} if results.nil?

    if results['total_pages'] != page
      results['results'] += search(page: page + 1, query: query, type: type)['results']
    end
    results
  end

  def episode(tv_id:, season_number:, episode_number:)
    request("tv/#{tv_id}/season/#{season_number}/episode/#{episode_number}")
  end

  def season(tv_id:, season_number:)
    request("tv/#{tv_id}/season/#{season_number}")
  end

  # This build a bunch of uniq names that can be used to build the names of the files.
  # These uniq names work best as they play nice with the Plex data and plus then you can
  # tell if you have which movie is from 1999 and 2032.
  # Example:
  #   uniq_names(search(query: 'dark', type: 'tv'))
  #
  def uniq_names(search_results)
    names_hash = Hash.new(0)
    search_results.map do |result|
      names_hash[parse_name(result)] += 1
      if names_hash[parse_name(result)] > 1
        extra_info = if result['first_air_date'].to_s != ''
                       Time.parse(result['first_air_date'].to_s).year
                     else
                       result['id']
                     end
        "#{parse_name(result)} (#{extra_info})"
      else
        parse_name(result)
      end
    end
  end

  # Movies name the titles and tv shows name the names
  # This is just so I can standardize the lookup
  def parse_name(result)
    result['title'] || result['name']
  end

  def video(type:, id:)
    request("#{type}/#{id}")
  end

  def runtime(type:, id:)
    response = video(type: type, id: id)

    if type == :tv
      episode_run_time = response['episode_run_time'] || [0]
      { min: episode_run_time.min, max: episode_run_time.max }
    else
      runtime = response['runtime'].to_i
      { min: runtime, max: runtime }
    end
  end
end
