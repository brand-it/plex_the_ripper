# frozen_string_literal: true

class SeasonsController < ApplicationController
  def show
    @tv = Tv.find(params[:tv_id])
    @season = Season.find(params[:id])
    @season.subscribe(TheMovieDbSeasonListener.new)
    @season.save
    @disks = Disk.not_ejected
  end

  def rip # rubocop:disable Metrics/AbcSize
    tv = Tv.find(params[:tv_id])
    season = tv.seasons.find(params[:id])
    episodes = params[:episodes].reject { _1[:disk_title_id].blank? }
    episodes = episodes.map do |episode_param|
      episode = season.episodes.find { _1.id == episode_param[:id].to_i }
      episode.update!(disk_title_id: episode_param[:disk_title_id])
      episode
    end

    job = RipWorker.perform_async(disk_title_ids: episodes.map(&:disk_title_id))
    redirect_to job_path(job)
  end
end
