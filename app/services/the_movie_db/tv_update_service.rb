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

    class << self
      def call(*)
        new(*).call
      end
    end

    def call
      return if tv.the_movie_db_id.nil?

      tv.attributes = tv_params
      build_seasons
    end

    def db_tv
      @db_tv ||= TheMovieDb::Tv.new(tv.the_movie_db_id).results
    end

    private

    def tv_params
      db_tv.slice(*PERMITTED_PARAMS).tap do |params|
        params[:episode_distribution_runtime] = db_tv['episode_run_time'].sort
        params[:episode_first_air_date] = db_tv['first_air_date']
        params[:synced_on] = Time.current
      end
    end

    def build_seasons
      db_tv['seasons'].each do |season|
        tv.seasons.build(season.slice(*SEASON_PERMITTED_PARAMS)).tap do |tv_season|
          tv_season.the_movie_db_id = season['id']
        end
      end
    end
  end
end
