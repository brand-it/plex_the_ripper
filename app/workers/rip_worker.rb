# frozen_string_literal: true

class RipWorker < ApplicationWorker
  option :disk_title_ids, Types::Array.of(Types::Integer)

  def call
    disk_titles.each do |disk_title|
      create_mkv(disk_title) unless disk_title.video.tmp_plex_path_exists?
      UploadWorker.perform_async(disk_title: disk_title)
    end
  end

  private

  def create_mkv(disk_title)
    CreateMkvService.new(disk_title: disk_title, progress_listener: MkvProgressListener.new).call
  end

  def disk_titles
    @disk_titles ||= DiskTitle.where(id: disk_title_ids)
  end
end
