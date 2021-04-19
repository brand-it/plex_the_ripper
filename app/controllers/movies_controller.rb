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

  # def rip
  #   @movie       = movie
  #   @disk_titles = disk_titles
  #   @movie.select_disk_titles!(@disk_titles)
  #   @movie.save!
  #   @movie.rip!
  #   @movie.save!
  # end

  def drives
    ListDrivesService.results
  end

  def movie
    Movie.find(params[:id])
  end

  def disk_titles
    DiskTitle.where(id: params[:disk_title_ids])
  end
end
