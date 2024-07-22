# frozen_string_literal: true

class UploadProcessComponent < ViewComponent::Base
  def self.job
    UploadWorker.job
  end

  def dom_id
    'upload-process-component'
  end

  def uploadable_video_blobs
    @uploadable_video_blobs ||= VideoBlob.where(uploadable: true)
  end

  def job_active?
    job&.active?
  end

  def job
    @job ||= UploadWorker.job
  end

  def ftp_host
    Config::Plex.newest.settings_ftp_host
  end
end
