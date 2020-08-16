# frozen_string_literal: true

class MoviesController < ApplicationController

  def show
    @movie = Movie.find(params[:id])
  end

  def create
    @movie = Movie.find_or_initialize_by(the_movie_db_id: params[:movie_id])
    @movie.subscribe(TheMovieDbListener.new)

    if @movie.save
      flash[:success] = 'Movie was created successfully created'
      redirect_to movie_path(@movie)
    else
      render :new
    end
  end
end
