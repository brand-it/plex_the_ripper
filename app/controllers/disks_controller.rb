# frozen_string_literal: true

class DisksController < ApplicationController
  def reload
    Disk.destroy_all
    LoadDiskWorker.perform
    Disk.all_valid?
    render DiskCardComponent.new(disks: [])
  end

  def build
    movie = Movie.first
    movie.mkv_progresses.destroy_all
    CreateMovieWorker.perform(movie: movie, disk_title: DiskTitle.first)
    render VideoProgressComponent.new(video: movie)
  end
end
