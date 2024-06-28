# frozen_string_literal: true

module TheMovieDb
  class TvUpdateService
    extend Dry::Initializer

    PERMITTED_PARAMS = %w[
      name
      original_name
      year
      poster_path
      backdrop_path
      overview
    ].freeze
    SEASON_PERMITTED_PARAMS = %w[name overview poster_path season_number air_date].freeze

    param :tv, Types.Instance(::Tv)
    param :the_movie_db_details, Types::Coercible::Hash

    class << self
      def call(*)
        new(*).call
      end
    end

    def call
      tv.attributes = tv_params.symbolize_keys
      build_seasons
      delete_missing
    end

    private

    def tv_params
      the_movie_db_details.slice(*PERMITTED_PARAMS).tap do |params|
        params[:episode_distribution_runtime] = Array.wrap(the_movie_db_details['episode_run_time']).sort
        params[:episode_first_air_date] = the_movie_db_details['first_air_date']
        params[:synced_on] = Time.current
      end
    end

    def delete_missing
      the_movie_db_ids = the_movie_db_details['seasons'].map { _1['id'].to_i }
      tv.seasons.each do |season|
        next if the_movie_db_ids.include?(season.the_movie_db_id)

        season.mark_for_destruction
      end
    end

    def build_seasons
      Array.wrap(the_movie_db_details['seasons']).each do |season|
        find_or_build(season['id']).tap do |tv_season|
          tv_season.attributes = season.slice(*SEASON_PERMITTED_PARAMS).symbolize_keys
        end
      end
    end

    def find_or_build(the_movie_db_id)
      tv.seasons.find { _1.the_movie_db_id == the_movie_db_id.to_i } ||
        tv.seasons.build(the_movie_db_id: the_movie_db_id.to_i)
    end
  end
end
