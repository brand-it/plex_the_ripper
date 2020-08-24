# frozen_string_literal: true

class StartController < ApplicationController
  def new
    if movie_db_config.settings_invalid?
      redirect_to config_the_movie_db_path
    elsif plex_config.settings_invalid?
      redirect_to config_plex_plex
    else
      redirect_to the_movie_dbs_path
    end
  end

  def create
    @config_the_movie_db = Config::TheMovieDb.new(the_movie_db_params)

    @config_the_movie_db.save
    render :new
  end
end
