# frozen_string_literal: true

class MoviesController < ApplicationController
  before_action :movie
  def show; end

  def select_disk_title
    if movie.rip!
      flash[:success] = 'Started Ripping movie'
    else
      flash[:error] = 'Failed to start ripping for movie'
    end
    redirect_to movie_path(movie)
  end

  def select
    movie.subscribe(TheMovieDbMovieListener.new)

    if movie.select!
      flash[:success] = 'Movie has been selected and is ready.'
      redirect_to movie_path(movie)
    else
      render :new
    end
  end

  private

  def movie
    @movie ||= if params.key?(:the_movie_db_id)
                 Movie.find_or_initialize_by(the_movie_db_id: movie_params[:the_movie_db_id])
               else
                 Movie.find(params[:id])
               end
  end
end
