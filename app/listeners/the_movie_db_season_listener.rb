# frozen_string_literal: true

class TheMovieDbSeasonListener
  PERMITTED_PARAMS = %i[name overview poster_path season_number air_date].freeze
  EPISODE_PERMITTED_PARAMS = %i[name episode_number overview air_date].freeze
  def season_saving(season)
    db_season = TheMovieDb::Season.new(season.tv.the_movie_db_id, season.season_number).results
    season.attributes = season_params(db_season)
    build_episodes(season, db_season)
  end

  private

  def season_params(db_season)
    db_season.to_h.slice(*PERMITTED_PARAMS)
  end

  def build_episodes(season, db_season)
    db_season.episodes.each do |episode|
      season.episodes.build(episode.to_h.slice(*EPISODE_PERMITTED_PARAMS)).tap do |tv_season|
        tv_season.the_movie_db_id = episode.id
      end
    end
  end
end
