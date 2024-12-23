# frozen_string_literal: true

class LoadDiskProcessComponent < ViewComponent::Base
  extend Dry::Initializer

  def self.job
    Backgrounder.managers.find { _1.current_job&.name == 'LoadDiskWorker' }&.current_job
  end

  def self.show?
    job&.active?
  end

  def hidden?
    !self.class.show? && disks_not_ejected.empty?
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
