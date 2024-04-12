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
      def call(*)
        new(*).call
      end
    end

    def call
      return if movie.the_movie_db_id.nil?

      movie.attributes = movie_params.merge(synced_on: Time.current)
    end

    private

    def movie_params
      movie.the_movie_db_details.symbolize_keys.slice(*PERMITTED_PARAMS).tap do |params|
        params[:movie_runtime] = convert_min_to_seconds(movie.the_movie_db_details['runtime'])
        params[:rating] = movie.ratings.first || Video.ratings['N/A']
      end
    end

    def convert_min_to_seconds(min)
      min.to_i * 60
    end
  end
end
