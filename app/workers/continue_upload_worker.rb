# frozen_string_literal: true

class ContinueUploadWorker < ApplicationWorker
  def perform
    Movie.find_each do |movie|
      next unless movie.tmp_plex_path_exists?

      UploadWorker.perform_async(disk_title_id: movie.disk_title.id)
    end
  end
end
