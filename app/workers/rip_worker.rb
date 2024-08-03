# frozen_string_literal: true

class RipWorker < ApplicationWorker
  include ActionView::Helpers::UrlHelper
  delegate :movie_url, :tv_season_url, to: 'Rails.application.routes.url_helpers'

  option :disk_id, Types::Integer
  option :disk_title_ids, Types::Array.of(Types::Integer)
  option :extra_types, Types::Array.of(Types::String), optional: true, default: -> { [] }

  def enqueue?
    true
  end

  def perform
    create_mkvs.tap do |results|
      if results.all?(&:success?)
        eject_disk
        redirect_to_season_or_movie
      end
    end
  end

  private

  def create_mkvs
    disk_title_ids.zip(extra_types).filter_map do |disk_title_id, extra_type|
      disk_title = DiskTitle.find(disk_title_id)
      service = CreateMkvService.new(disk_title:, extra_type:)
      service.subscribe(MkvProgressListener.new(job:))
      result = service.call
      upload_mkv(disk_title) if result.success?
      result
    end
  end

  def eject_disk
    service = EjectDiskService.new(disk)
    service.subscribe(DiskListener.new(disk:))
    service.call
  end

  def upload_mkv(disk_title)
    UploadWorker.perform_async(video_blob_id: disk_title.video_blob_id)
  end

  def disk
    @disk ||= Disk.find(disk_id)
  end

  def redirect_to_season_or_movie
    reload_page! if redirect_url.blank?
    cable_ready[BroadcastChannel.channel_name].redirect_to(url: redirect_url)
    cable_ready.broadcast
  end

  def redirect_url
    disk_title = DiskTitle.find(disk_title_ids.first)
    if disk_title.video.is_a?(Movie)
      movie_url(disk_title.video)
    elsif disk_title.video.is_a?(Tv)
      tv_season_url(disk_title.episode.season.tv, disk_title.episode.season)
    end
  end

  def reload_page!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end
end
