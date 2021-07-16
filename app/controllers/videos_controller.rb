# frozen_string_literal: true

class VideosController < ApplicationController
  def select_disk_titles
    if movie.select_disk_titles
      flash[:success] = 'Started Ripping movie'
    else
      flash[:error] = 'Failed to start ripping for movie'
    end
    redirect_to movie_path(movie)
  end

  private

  def disk_titles
    DiskTitle.where
  end

  def video
    @video ||= Video.find(params[:id])
  end
end
