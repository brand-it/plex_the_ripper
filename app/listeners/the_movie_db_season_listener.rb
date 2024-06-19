# frozen_string_literal: true

class TheMovieDbSeasonListener
  PERMITTED_PARAMS = %w[name overview poster_path season_number air_date].freeze
  EPISODE_PERMITTED_PARAMS = %w[name episode_number overview air_date still_path runtime].freeze
  def season_saving(season)
    db_season = TheMovieDb::Season.new(season.tv.the_movie_db_id, season.season_number).results
    season.attributes = season_params(db_season)
    build_episodes(season, db_season)
  end

  private

  def season_params(db_season)
    db_season.slice(*PERMITTED_PARAMS)
  end

  def build_episodes(season, db_season)
    db_season['episodes'].each do |episode|
      episode = episode.with_indifferent_access
      season.episodes.find_or_initialize_by(episode_number: episode[:episode_number]).tap do |tv_season|
        tv_season.attributes = episode.slice(*EPISODE_PERMITTED_PARAMS)
        tv_season.the_movie_db_id = episode[:id]
        tv_season.save!
      end
    end
  end
end
