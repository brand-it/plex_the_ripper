# frozen_string_literal: true

class MoviesController < ApplicationController
  # movie GET    /movies/:id(.:format)
  def show
    @movie = Movie.find_or_initialize_by(the_movie_db_id: params[:id])
    @movie.subscribe(TheMovieDb::MovieListener.new)
    @movie.save!
    @disks = Disk.not_ejected
  end

  # rip_movie POST   /movies/:id/rip(.:format)
  def rip
    movie = Movie.find(params[:id])
    disk_title = DiskTitle.find(params[:disk_title_id])
    disk_title.update!(video: movie)
    job = RipWorker.perform_async(disk_id: disk_title.disk.id, disk_title_ids: [disk_title.id])
    redirect_to job_path(job)
  end
end
