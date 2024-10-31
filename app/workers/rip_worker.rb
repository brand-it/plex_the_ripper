# frozen_string_literal: true

class RipWorker < ApplicationWorker
  include ActionView::Helpers::UrlHelper

  DiskTitleHash = Types::Hash.schema(
    id: Types::Coercible::Integer,
    edition?: Types::String.optional,
    extra_type?: Types::Coercible::Symbol,
    part?: Types::Coercible::Integer.optional.constructor { _1.to_i.positive? ? _1 : nil }
  ).with_key_transform(&:to_sym)
  delegate :movie_url, :tv_season_url, to: 'Rails.application.routes.url_helpers'

  option :disk_id, Types::Integer
  option :disk_titles, Types::Array.of(DiskTitleHash)

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
    disk_titles.filter_map do |disk_title|
      service = CreateMkvService.new(
        disk_title: DiskTitle.find(disk_title[:id]),
        extra_type: disk_title[:extra_type],
        edition: disk_title[:edition],
        part: disk_title[:part]
      )
      service.subscribe(MkvProgressListener.new(job:))
      result = service.call
      upload_mkv(service.disk_title) if result.success?
      result
    end
  end

  def eject_disk
    service = EjectDiskService.new(disk)
    service.subscribe(DiskListener.new)
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
    disk_title = DiskTitle.find_by(id: disk_titles.first[:id])
    return if disk_title.nil?

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
