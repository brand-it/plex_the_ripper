# frozen_string_literal: true

class UploadWorker < ApplicationWorker
  option :disk_title, Types.Instance(DiskTitle)

  def call
    Ftp::UploadMkvService.new(
      disk_title: title,
      progress_listener: UploadProgressListener.new(file_size: disk_title.size)
    ).call
  end
end
