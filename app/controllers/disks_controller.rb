# frozen_string_literal: true

class DisksController < ApplicationController
  def index
    @disks = Disk.all
  end
  # def reload
  #   Disk.destroy_all
  #   LoadDiskWorker.perform_async
  #   Disk.all_valid?
  #   render DiskCardComponent.new(disks: [])
  # end

  # def build
  #   movie = Movie.first
  #   movie.mkv_progresses.destroy_all
  #   CreateMovieWorker.perform_async(movie: movie, disk_title: DiskTitle.first)
  #   render VideoProgressComponent.new(video: movie)
  # end
end
