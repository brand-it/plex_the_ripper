# frozen_string_literal: true

class ScanPlexProcessComponent < ViewComponent::Base
  extend Dry::Initializer

  def self.job
    Job.sort_by_created_at.active.find_by(name: 'ScanPlexWorker')
  end

  def self.show?
    job&.active? || false
  end

  def hidden?
    !self.class.show?
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
    job&.active?
  end

  def ftp_host
    Config::Plex.newest.settings_ftp_host
  end

  def dom_id
    'scan-plex-process-component'
  end
end
