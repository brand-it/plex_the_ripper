# frozen_string_literal: true

class RipWorker < ApplicationWorker
  option :disk_title_ids, Types::Array.of(Types::Integer)

  def perform
    results = disk_titles.map do |disk_title|
      result = create_mkv(disk_title) unless disk_title.video.tmp_plex_path_exists?
      job.save!
      upload_mkv(disk_title)
      result
    end
    eject(results)
    reload_page
  end

  def progress_listener
    @progress_listener ||= MkvProgressListener.new(job:)
  end

  private

  def reload_page
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end

  def eject(results)
    return unless results.all?(&:success?)

    disk_titles.map(&:disk).uniq.each do |disk|
      EjectDiskService.call(disk)
    end
  end

  def create_mkv(disk_title)
    CreateMkvService.call disk_title:,
                          progress_listener:
  end

  def upload_mkv(disk_title)
    UploadWorker.perform_async(disk_title_id: disk_title.id)
  end

  def disk_titles
    @disk_titles ||= DiskTitle.where(id: disk_title_ids)
  end
end
