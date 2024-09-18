# frozen_string_literal: true

class UploadWorker < ApplicationWorker
  option :video_blob_id, Types::Integer

  def enqueue?
    true
  end

  def perform
    video_blob = VideoBlob.find(video_blob_id)
    return unless video_blob.uploadable?

    service = Ftp::UploadMkvService.new(video_blob:)
    service.subscribe(UploadProgressListener.new(
                        video_blob:,
                        job:
                      ))
    service.call
  end
end
