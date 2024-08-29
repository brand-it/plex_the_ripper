# frozen_string_literal: true

class LoadDiskProcessComponent < ViewComponent::Base
  extend Dry::Initializer

  def self.job
    Job.sort_by_created_at.active.find_by(name: 'LoadDiskWorker')
  end

  def job_active?
    job&.active?
  end

  def job
    @job ||= self.class.job
  end

  def recent_job
    @recent_job ||= Job.where(name: 'LoadDiskWorker')
                       .completed
                       .order(created_at: :desc)
                       .first
  end

  def disks_loading
    @disks_loading ||= Disk.loading
  end

  def disks_not_ejected
    @disks_not_ejected ||= Disk.not_ejected
  end

  def dom_id
    'load-disk-process-component'
  end
end
