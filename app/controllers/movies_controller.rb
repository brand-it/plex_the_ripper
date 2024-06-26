# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    @movie = Movie.find_or_initialize_by(the_movie_db_id: params[:id])
    @movie.subscribe(TheMovieDb::MovieListener.new)
    @movie.save
    @disks = Disk.not_ejected
  end
end
