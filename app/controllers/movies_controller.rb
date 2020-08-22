# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    @movie = Movie.find(params[:id])
  end

  def create
    @movie = Movie.find_or_initialize_by(movie_params)
    @movie.subscribe(TheMovieDbMovieListener.new) if @movie.the_movie_db_id

    if @movie.save
      flash[:success] = 'Movie was created successfully created'
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
