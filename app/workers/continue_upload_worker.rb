# frozen_string_literal: true

class ContinueUploadWorker < ApplicationWorker
  def enqueue?
    pending_disk_titles.any?
  end

  def perform
    pending_disk_titles.each do |disk_title|
      UploadWorker.perform_async(disk_title_id: disk_title.id)
    end
  end

  def pending_disk_titles
    @pending_disk_titles ||= DiskTitle.all.select(&:tmp_plex_path_exists?)
  end
end
