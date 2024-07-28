# frozen_string_literal: true

class RipProcessComponent < ViewComponent::Base
  def self.job
    RipWorker.job
  end

  def job
    self.class.job
  end

  def hide
    params[:controller] == 'jobs' && params[:id] == RipWorker.job&.id && params[:action] == 'show'
  end

  def dom_id
    'rip-process-component'
  end

  def job_active?
    job&.active?
  end

  def ftp_host
    Config::Plex.newest.settings_ftp_host
  end

  def eta
    return if !job_active? || job.metadata['completed'].to_f >= 100.0

    percentage_completed = job.metadata['completed'].to_f
    elapsed_time = Time.current - job.started_at

    total_time_estimated = elapsed_time / (percentage_completed / 100)
    remaining_time = total_time_estimated - elapsed_time

    eta = Time.current + remaining_time

    distance_of_time_in_words(eta, Time.current)
  rescue StandardError => e
    Rails.logger.debug { "#{e.message} #{job.started_at} #{job.metadata['completed']}" }
    Rails.logger.debug { e.backtrace.join("\n") }
    nil
  end
end
