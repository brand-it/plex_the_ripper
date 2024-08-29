# frozen_string_literal: true

class UploadProcessComponent < ViewComponent::Base
  def self.job
    Job.sort_by_created_at.active.find_by(name: 'UploadWorker')
  end

  def dom_id
    'upload-process-component'
  end

  def uploadable_video_blobs
    @uploadable_video_blobs ||= VideoBlob.uploadable
                                         .order(updated_at: :desc)
  end

  def percentage(completed, total)
    (completed.to_i / total.to_f) * 100
  end

  def uploaded_recently_video_blobs
    @uploaded_recently_video_blobs ||= VideoBlob.uploaded_recently
                                                .order(uploaded_on: :desc)
                                                .limit(3)
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

  def eta(job, blob)
    percentage_completed = percentage(job.completed, blob.byte_size)
    elapsed_time = Time.current - job.started_at

    total_time_estimated = elapsed_time / (percentage_completed / 100)
    remaining_time = total_time_estimated - elapsed_time

    eta = Time.current + remaining_time

    distance_of_time_in_words(eta, Time.current)
  rescue StandardError => e
    Rails.logger.debug { "#{e.message} #{job.started_at} #{job.completed}" }
    Rails.logger.debug { e.backtrace.join("\n") }
    nil
  end
end
