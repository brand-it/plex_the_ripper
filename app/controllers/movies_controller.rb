# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    @movie = Movie.find(params[:id])
  end

  def create
    @movie = Movie.find_or_initialize_by(the_movie_db_id: params[:the_movie_db_id])
    @movie.subscribe(TheMovieDbMovieListener.new)

    if @movie.save
      redirect_to @movie
    else
      render :new # This is going to be weird because you go from show to new
    end
  end

  def select_disk_title
    if movie.rip!
      flash[:success] = 'Started Ripping movie'
    else
      flash[:error] = 'Failed to start ripping for movie'
    end
    redirect_to movie_path(movie)
  end
end
