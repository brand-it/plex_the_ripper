# frozen_string_literal: true

class UploadWorker < ApplicationWorker
  option :disk_title_id, Types::Integer

  def perform
    disk_title = DiskTitle.find(disk_title_id)
    service = Ftp::UploadMkvService.new(disk_title:)
    service.subscribe(UploadProgressListener.new(disk_title:, file_size: disk_title.size))
    service.call
  end
end
