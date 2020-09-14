# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    @movie = Movie.find(params[:id])
  end

  def rip
    @movie = Movie.find(params[:id])
    if @movie.rip!
      flash[:success] = 'Started Ripping movie'
    else
      flash[:error] = 'Failed to start ripping for movie'
    end
    redirect_to movie_path(@movie)
  end

  def create
    @movie = Movie.find_or_initialize_by(the_movie_db_id: movie_params[:the_movie_db_id])
    @movie.subscribe(TheMovieDbMovieListener.new) if @movie.the_movie_db_id

    if @movie.save
      @movie.select!
      flash[:success] = 'Movie has been selected and is ready.'
      redirect_to movie_path(@movie)
    else
      render :new
    end
  end

  private

  def movie_params
    params.require(:movie).permit(:the_movie_db_id)
  end
end
