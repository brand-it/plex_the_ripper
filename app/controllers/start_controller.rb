# frozen_string_literal: true

class StartController < ApplicationController
  def new
    config = Config::TheMovieDb.newest.first
    if config&.settings&.api_key.present?
      redirect_to the_movie_dbs_path
    elsif config
      redirect_to edit_config_the_movie_db_path(config)
    else
      redirect_to new_config_the_movie_db_path
    end
  end

  # Get /start
  def create
    @config_the_movie_db = Config::TheMovieDb.new(the_movie_db_params)

    @config_the_movie_db.save
    render :new
  end
end
