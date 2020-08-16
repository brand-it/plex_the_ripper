# frozen_string_literal: true

class StartController < ApplicationController
  def new
    if movie_db_config.settings_invalid?
      redirect_to_config_the_movie_db
    elsif plex_config.settings_invalid?
      redirect_to_config_plex
    else
      redirect_to the_movie_dbs_path
    end
  end

  def create
    @config_the_movie_db = Config::TheMovieDb.new(the_movie_db_params)

    @config_the_movie_db.save
    render :new
  end

  private

  def redirect_to_config_the_movie_db
    if movie_db_config.persisted?
      redirect_to edit_config_the_movie_db_path(movie_db_config)
    else
      redirect_to new_config_the_movie_db_path
    end
  end

  def redirect_to_config_plex
    if plex_config.persisted?
      redirect_to edit_config_plex_path(plex_confg)
    else
      redirect_to edit_config_plex_path
    end
  end

  def plex_config
    @plex_config ||= Config::Plex.newest.first || Config::Plex.new
  end

  def movie_db_config
    @movie_db_config ||= Config::TheMovieDb.newest.first || Config::TheMovieDb.new
  end
end
