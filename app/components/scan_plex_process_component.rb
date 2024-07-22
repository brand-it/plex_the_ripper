# frozen_string_literal: true

class ScanPlexProcessComponent < ViewComponent::Base
  def self.job
    ScanPlexWorker.job
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
