# frozen_string_literal: true

class UploadWorker < ApplicationWorker
  option :disk_title, Types.Instance(DiskTitle)

  def perform
    progress_listener = UploadProgressListener.new(
      title: "Uploading #{disk_title.video.title}",
      file_size: disk_title.size
    )
    Ftp::UploadMkvService.call disk_title:,
                               progress_listener:
  end
end
