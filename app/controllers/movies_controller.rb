# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    @movie = movie
    @disks = CreateDisksService.call
  end

  def create
    movie = Movie.new(the_movie_db_id: params[:the_movie_db_id])
    movie.subscribe(TheMovieDb::MovieListener.new)
    if movie.save
      redirect_to movie
    else
      redirect_to the_movie_dbs_path, flash: { error: movie.errors.full_messages }
    end
  end

  def movie
    Movie.find(params[:id])
  end
end
