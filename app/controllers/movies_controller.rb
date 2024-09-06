# frozen_string_literal: true

class MoviesController < ApplicationController
  # movie GET    /movies/:id(.:format)
  def show
    @movie = if params[:id].start_with?('tmdb:')
               Movie.find_or_initialize_by(the_movie_db_id: params[:id].split(':').last)
             else
               Movie.find(params[:id])
             end
    @movie.subscribe(TheMovieDb::VideoListener.new)
    @movie.save!
    @disks = Disk.not_ejected
  end

  # rip_movie POST   /movies/:id/rip(.:format)
  def rip
    movie = Movie.find(params[:id])
    disk = Disk.find(params[:disk_id])
    disk_titles = rip_disk_titles(disk, movie)
    job = RipWorker.perform_async(
      disk_id: disk.id,
      disk_title_ids: disk_titles.map(&:id),
      extra_types: movies_params.pluck(:extra_type).compact_blank
    )
    redirect_to job_path(job)
  end

  # Call this method to auto start ripping the disk as soon as it the disk title is ready
  # It will auto select disk titles for you rather then you selecting them
  def auto_start
    movie = Movie.find(params[:id])
    Video.auto_start.in_batches { _1.update(auto_start: false) }
    movie.update!(auto_start: true)
    flash[:notice] = "Once disk is loaded is ready we will start processings #{movie.title}"
    redirect_to movie_path(movie)
  end

  def cancel_auto_start
    movie = Movie.find(params[:id])
    movie.update!(auto_start: false)
    flash[:notice] = "Removed #{movie.title} from auto start"
    redirect_back_or_to :root
  end

  private

  def rip_disk_titles(disk, movie)
    movies_params.filter_map do |movie_params|
      next if movie_params[:extra_type].blank?

      disk_title = disk.disk_titles.find(movie_params[:disk_title_id])
      disk_title.update!(video: movie)
      disk_title
    end
  end

  def movies_params
    params.required(:movies)
  end
end
