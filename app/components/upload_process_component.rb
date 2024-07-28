# frozen_string_literal: true

class UploadProcessComponent < ViewComponent::Base
  def self.job
    UploadWorker.job
  end

  def dom_id
    'upload-process-component'
  end

  def uploadable_video_blobs
    @uploadable_video_blobs ||= VideoBlob.uploadable
  end

  def uploaded_recently_video_blobs
    @uploaded_recently_video_blobs ||= VideoBlob.uploaded_recently
  end

  def job_active?
    job&.active?
  end

  def job
    @job ||= self.class.job
  end

  def ftp_host
    Config::Plex.newest.settings_ftp_host
  end

  def find_job_by_video_blob(blob)
    return if blob.nil? || !job_active?

    job if job.metadata['video_blob_id'].to_i == blob.id
  end
end
