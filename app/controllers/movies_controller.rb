# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    @movie = movie
    fetch_disk
    if @movie.new?
      @movie.select!
      @movie.save!
    else
      @movie.touch # rubocop:disable Rails/SkipsModelValidations
    end
    LoadDiskWorker.perform unless @disk&.completed?
  end

  def rip
    fetch_disk_titles
    @movie.select_disk_titles!(@disk_titles)
    @movie.save!
    @movie.rip!
    @movie.save!
  end

  def fetch_disk
    @disk = Disk.first
  end

  def movie
    Movie.find(params[:id])
  end

  def fetch_disk_titles
    @disk_titles = DiskTitle.where(id: params[:disk_title_ids])
  end
end
