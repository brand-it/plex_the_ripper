# frozen_string_literal: true

class ContinueUploadWorker < ApplicationWorker
  def enqueue?
    (pending_movies + pending_episodes).any?
  end

  def perform
    DiskTitle.find_each do |disk_title|
      next unless disk_title.tmp_plex_path_exists?

      UploadWorker.perform_async(disk_title_id: disk_title.id)
    end
  end
end
