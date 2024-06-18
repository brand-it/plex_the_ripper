# frozen_string_literal: true

module TheMovieDb
  class MovieUpdateService
    extend Dry::Initializer

    PERMITTED_PARAMS = %w[
      backdrop_path
      original_title
      overview
      popularity
      poster_path
      release_date
      title
    ].freeze
    param :movie, Types.Instance(::Movie)
    param :the_movie_db_details, Types::Coercible::Hash

    class << self
      def call(*)
        new(*).call
      end
    end

    def call
      movie.attributes = movie_params.symbolize_keys
    end

    private

    def movie_params
      the_movie_db_details.slice(*PERMITTED_PARAMS).tap do |params|
        params[:movie_runtime] = convert_min_to_seconds(the_movie_db_details['runtime'])
        params[:synced_on] = Time.current
      end
    end

    def convert_min_to_seconds(min)
      min.to_i * 60
    end
  end
end
