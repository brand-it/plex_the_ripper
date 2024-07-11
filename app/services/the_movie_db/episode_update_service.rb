# frozen_string_literal: true

module TheMovieDb
  class EpisodeUpdateService
    extend Dry::Initializer
    EPISODE_PERMITTED_PARAMS = %w[name episode_number overview air_date still_path runtime].freeze

    param :season, Types.Instance(::Season)

    def self.call(...)
      new(...).call
    end

    def call
      db_season['episodes'].each do |episode_attributes|
        episode_attributes = episode_attributes.with_indifferent_access
        find_or_build(episode_attributes[:id]).tap do |episode|
          episode.attributes = episode_attributes.slice(*EPISODE_PERMITTED_PARAMS)
        end
      end
    end

    private

    def find_or_build(the_movie_db_id)
      season.episodes.find { _1.the_movie_db_id == the_movie_db_id.to_i } ||
        season.episodes.build(the_movie_db_id: the_movie_db_id.to_i)
    end

    def db_season
      @db_season ||= TheMovieDb::Season.new(season.tv.the_movie_db_id, season.season_number).results
    end
  end
end
