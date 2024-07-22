# frozen_string_literal: true

class RipProcessComponent < ViewComponent::Base
  def self.job
    RipWorker.job
  end

  def hide
    params[:controller] == 'jobs' && params[:id] == RipWorker.job&.id
  end

  def dom_id
    'rip-process-component'
  end

  def job_active?
    RipWorker.job&.active?
  end

  def ftp_host
    Config::Plex.newest.settings_ftp_host
  end
end
