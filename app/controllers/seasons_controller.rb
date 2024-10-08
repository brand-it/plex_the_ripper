# frozen_string_literal: true

class SeasonsController < ApplicationController
  def show
    @tv = Tv.find(params[:tv_id])
    @season = @tv.seasons.includes(episodes: [:ripped_disk_titles]).find(params[:id])
    @season.subscribe(TheMovieDb::EpisodesListener.new)
    @season.save!
    @disks = Disk.not_ejected
  end

  def rip
    tv = Tv.find(params[:tv_id])
    season = tv.seasons.find(params[:id])
    disk = Disk.find(params[:disk_id])
    disk_titles = rip_disk_titles(tv, disk, season)
    job = RipWorker.perform_async(disk_id: disk.id, disk_titles:)
    redirect_to job_path(job)
  end

  private

  def rip_disk_titles(tv, disk, season)
    episode_params.map do |episode_param|
      episode = season.episodes.find { _1.id == episode_param[:id].to_i }
      disk_title = disk.disk_titles.find { _1.id == episode_param[:disk_title_id].to_i }
      disk_title.update!(video: tv, episode:)
      { id: disk_title.id }
    end
  end

  def episode_params
    params[:episodes].reject { _1[:disk_title_id].blank? }
  end
end
