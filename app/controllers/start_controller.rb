# frozen_string_literal: true

class StartController < ApplicationController
  def new
    if Config::TheMovieDb.authorized?
      render :new
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
