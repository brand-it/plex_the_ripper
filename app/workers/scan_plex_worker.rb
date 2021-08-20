# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def call
    plex_movies.map do |blob|
      blob.update!(video: create_movie!(blob))
    end
  end

  private

  def search_for_movie(blob) # rubocop:disable Metrics/AbcSize Metrics/CyclomaticComplexity Metrics/PerceivedComplexity
    options = { query: blob.parsed_dirname.title, year: blob.parsed_dirname.year }.compact
    dirname = TheMovieDb::Search::Movie.new(options) if options[:query].present?

    options = { query: blob.parsed_filename.title, year: blob.parsed_filename.year }.compact
    filename = TheMovieDb::Search::Movie.new(options) if options[:query].present?

    dirname&.results&.results&.first&.id || filename&.results&.results&.first&.id
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
