# frozen_string_literal: true

class RipWorker < ApplicationWorker
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

  delegate :movie_url, :tv_season_url, to: 'Rails.application.routes.url_helpers'

  option :disk_id, Types::Integer
  option :disk_title_ids, Types::Array.of(Types::Integer)
  option :extra_types, Types::Array.of(Types::String), optional: true

  def perform
    if create_mkvs.all?(&:success?)
      EjectDiskService.call(disk)
      redirect_to_season_or_movie
    else
      reload_page!
    end
  rescue StandardError => e
    reload_page!
    raise e
  end

  private

  def create_mkvs
    disk_title_ids.zip(extra_types).filter_map do |disk_title_id, extra_type|
      disk_title = DiskTitle.find(disk_title_id)
      service = CreateMkvService.new(disk_title:, extra_type:)
      service.subscribe(MkvProgressListener.new(job:, disk_title:))
      result = service.call
      job.save!
      upload_mkv(disk_title)
      result
    end
  end

  def reload_page!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end

  def redirect_to_season_or_movie
    reload_page! if redirect_url.blank?
    cable_ready[BroadcastChannel.channel_name].redirect_to(url: redirect_url)
    cable_ready.broadcast
  end

  def redirect_url
    if disk.video.is_a?(Movie)
      movie_url(disk.video)
    elsif disk.video.is_a?(Tv)
      tv_season_url(disk.episode.season.tv, disk.episode.season)
    end
  end

  def upload_mkv(disk_title)
    UploadWorker.perform_async(video_blob_id: disk_title.video_blob_id)
  end

  def disk
    @disk ||= Disk.find(disk_id)
  end

  def disk_titles
    @disk_titles ||= disk.disk_titles.where(id: disk_title_ids)
  end
end
