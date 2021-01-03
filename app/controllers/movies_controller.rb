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
    @movie ||= Movie.find_video(params[:id])
  end
end
