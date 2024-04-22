# frozen_string_literal: true

class RipWorker < ApplicationWorker
  option :disk_title_ids, Types::Array.of(Types::Integer)

  def perform
    disk_titles.each do |disk_title|
      create_mkv(disk_title) unless disk_title.video.tmp_plex_path_exists?
      upload_mkv(disk_title)
    end
  end

  def progress_listener
    @progress_listener ||= MkvProgressListener.new
  end

  private

  def create_mkv(disk_title)
    CreateMkvService.call disk_title:,
                          progress_listener:
  end

  def upload_mkv(disk_title)
    sleep 1 while UploadWorker.job.pending?
    UploadWorker.perform_async(disk_title:)
  end

  def disk_titles
    @disk_titles ||= DiskTitle.where(id: disk_title_ids)
  end
end
