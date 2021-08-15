# frozen_string_literal: true

module TheMovieDb
  class MovieUpdateService
    extend Dry::Initializer

    PERMITTED_PARAMS = %i[
      backdrop_path
      original_title
      overview
      popularity
      poster_path
      release_date
      title
    ].freeze

    param :movie, Types.Instance(::Movie)

    class << self
      def call(*args)
        new(*args).call
      end
    end

    def call
      return if movie.the_movie_db_id.nil?

      movie.attributes = movie_params(db_movie).merge(synced_on: Time.current)
    end

    def db_movie
      @db_movie ||= TheMovieDb::Movie.new(movie.the_movie_db_id).results
    end

    private

    def movie_params(db_movie)
      db_movie.to_h.slice(*PERMITTED_PARAMS).tap do |params|
        params[:movie_runtime] = convert_min_to_seconds(db_movie.runtime)
      end
    end

    def convert_min_to_seconds(min)
      min.to_i * 60
    end
  end
end
