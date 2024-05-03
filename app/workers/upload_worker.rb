# frozen_string_literal: true

class UploadWorker < ApplicationWorker
  option :disk_title_id, Types::Integer

  def perform
    disk_title = DiskTitle.find(disk_title_id)
    progress_listener = UploadProgressListener.new(
      title: "Uploading #{disk_title.video.title}",
      file_size: disk_title.size
    )
    Ftp::UploadMkvService.call disk_title:,
                               progress_listener:
  end
end
