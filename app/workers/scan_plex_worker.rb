# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  # rubocop:disable Layout/LineLength
  MOVIE_MATCHER_WITH_YEAR = /(?<title>.*)\s\((?<year>.*)\).*mkv/.freeze
  MOVIE_MATCHER = /(?<title>.*).*mkv/.freeze
  TV_SHOW_MATCHER_FULL = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_EP_NAME = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_DATE = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_NUMBER = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_YEAR = /(?<title>.*)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  # rubocop:enable Layout/LineLength

  def call
    plex_movies.each do |movie|
      matcher = movie_matcher(movie)
      next if matcher.nil?

      build_movie(search_for_movie(matcher.slice(:title, :year)))&.save
    end
  end

  private

  def search_for_movie(title:, year: nil)
    TheMovieDb::Search::Movie.new({query: title, year: year}.compact).results.results.first&.id
  end

  def build_movie(the_movie_db_id)
    return if the_movie_db_id.nil?

    Movie.find_or_initialize_by(the_movie_db_id: the_movie_db_id).tap do |m|
      m.subscribe(TheMovieDb::MovieListener.new)
    end
  end

  def movie_matcher(movie)
    match_data = movie[:file_name].match(MOVIE_MATCHER_WITH_YEAR) || movie[:file_name].match(MOVIE_MATCHER)
    match_data&.names&.to_h { |n| [n.to_sym, match_data[n]] }
  end

  def plex_movies
    Ftp::VideoScannerService.call.movies
  end
end
