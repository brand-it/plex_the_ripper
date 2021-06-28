# frozen_string_literal: true

class DiskTitlesController < ApplicationController
  def show
    @rip_worker = ApplicationWorker.find('RipWorker')&.worker
  end

  def update
    disk_title = DiskTitle.find(params[:id])
    RipWorker.perform(disk_title_ids: [disk_title.id])
    redirect_to disk_title
  end
  # def reload
  #   Disk.destroy_all
  #   LoadDiskWorker.perform
  #   Disk.all_valid?
  #   render DiskCardComponent.new(disks: [])
  # end

  # def build
  #   movie = Movie.first
  #   movie.mkv_progresses.destroy_all
  #   CreateMovieWorker.perform(movie: movie, disk_title: DiskTitle.first)
  #   render VideoProgressComponent.new(video: movie)
  # end
end
