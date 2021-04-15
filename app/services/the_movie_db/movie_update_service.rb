# frozen_string_literal: true

module TheMovieDb
  class MovieUpdateService
    extend Dry::Initializer

    PERMITTED_PARAMS = %i[
      title
      original_title
      release_date
      poster_path
      backdrop_path
      overview
    ].freeze

    option :movie, Types.Instance(::Movie)

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def call
      return if movie.the_movie_db_id.nil?

      movie.attributes = movie_params(db_movie).merge(synced_on: Time.current)
    end

    def db_movie
      @db_movie ||= TheMovieDb::Movie.new(movie.the_movie_db_id).body
    end

    private

    def movie_params(db_movie)
      db_movie.to_h.slice(*PERMITTED_PARAMS).tap do |params|
        params[:movie_runtime] = db_movie.runtime
      end
    end
  end
end
