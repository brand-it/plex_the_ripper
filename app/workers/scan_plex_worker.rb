# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def call
    plex_movies.map do |blob|
      blob.update!(video: create_movie!(blob))
    end
  end

  private

  def search_for_movie(movie)
    return if movie.parsed_filename.title.nil?

    options = { query: movie.parsed_filename.title, year: movie.parsed_filename.year }.compact
    TheMovieDb::Search::Movie.new(options).results.results.first&.id
  end

  def create_movie!(blob)
    the_movie_db_id = search_for_movie(blob)
    return if the_movie_db_id.nil?

    Movie.find_or_initialize_by(the_movie_db_id: the_movie_db_id).tap do |m|
      m.subscribe(TheMovieDb::MovieListener.new)
      m.save!
    end
  end

  def plex_movies
    Ftp::VideoScannerService.call.movies
  end
end
