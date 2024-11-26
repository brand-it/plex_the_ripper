# frozen_string_literal: true

class SeasonsController < ApplicationController
  def show
    @tv = Tv.includes(:ripped_disk_titles).find(params[:tv_id])
    @season = @tv.seasons.includes(
      :ripped_disk_titles,
      episodes: [
        { uploaded_video_blobs: %i[episode episode_last] }, { ripped_disk_titles: %i[episode_last] }, :video_blobs
      ]
    ).find(params[:id])
    @season.subscribe(TheMovieDb::EpisodesListener.new)
    @season.save!
    @disks = Disk.not_ejected.includes(:disk_titles)
  end

  def rip
    job = RipWorker.perform_async(disk_id: disk.id, disk_titles: rip_disk_titles)
    redirect_to job_path(job)
  end

  private

  def season
    @season ||= tv.seasons.includes(:episodes).find(params[:id])
  end

  def disk
    @disk ||= Disk.includes(disk_titles: [:episode]).find(params[:disk_id])
  end

  def tv
    @tv ||= Tv.find(params[:tv_id])
  end

  def rip_disk_titles
    disk_title_ids = []
    @rip_disk_titles ||= episode_params.filter_map do |episode_param|
      episode = season.episodes.find { _1.id == episode_param[:episode_id].to_i }
      disk_title = disk.disk_titles.find { _1.id == episode_param[:disk_title_id].to_i }
      if disk_title.episode
        disk_title.update!(video: tv, episode_last: episode)
      else
        disk_title.update!(video: tv, episode:)
      end
      next if disk_title_ids.include?(disk_title.id)

      disk_title_ids.append(disk_title.id)
      RipWorker::DiskTitleHash[{
        id: disk_title.id,
        part: episode_param[:part].presence&.to_i
      }]
    end
  end

  def episode_params
    params[:episodes].reject { _1[:episode_id].blank? || _1[:disk_title_id].blank? }.sort_by do |episode_param|
      season.episodes.find { _1.id == episode_param[:episode_id].to_i }.episode_number
    end
  end
end
