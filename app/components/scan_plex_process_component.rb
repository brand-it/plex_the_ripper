# frozen_string_literal: true

class ScanPlexProcessComponent < ViewComponent::Base
  extend Dry::Initializer

  def self.job
    ScanPlexWorker.job
  end

  def completed
    job.metadata['completed'].presence || 0.0
  end

  def status
    (completed >= 100 ? :success : :info)
  end

  def job
    self.class.job
  end

  def job_active?
    ScanPlexWorker.job&.active?
  end

  def ftp_host
    Config::Plex.newest.settings_ftp_host
  end

  def dom_id
    'scan-plex-process-component'
  end
end