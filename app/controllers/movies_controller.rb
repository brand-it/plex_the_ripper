# frozen_string_literal: true

class MoviesController < ApplicationController
  def new
    config = Config::TheMovieDb.newest.first
    if config&.settings&.api_key
      redirect_to the_movie_dbs_path
    elsif config
      redirect_to edit_config_the_movie_db_path(config)
    else
      redirect_to new_config_the_movie_db_path
    end
  end

  def create

    @movie = Movie.new(the_movie_db_id: params[:the_movie_db_id])

    if @movie.save
      render :new
    else

    end
  end
end
