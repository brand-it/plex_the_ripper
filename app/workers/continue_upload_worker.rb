# frozen_string_literal: true

class ContinueUploadWorker < ApplicationWorker
  def enqueue?
    pending_video_blobs.any?
  end

  def perform
    pending_video_blobs.find_each do |video_blob|
      UploadWorker.perform_async(video_blob_id: video_blob.id)
    end
  end

  def pending_video_blobs
    @pending_video_blobs ||= ::VideoBlob.where(uploaded_on: nil)
  end
end
