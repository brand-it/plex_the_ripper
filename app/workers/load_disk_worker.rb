# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def enqueue?
    Disk.verified_disks.empty?
  end

  def perform
    Disk.where.not(id: Disk.verified_disks.select(:id)).not_ejected.update_all(ejected: true)
    Disk.loading.update_all(loading: false)
    CreateDisksService.new(job:).tap do |service|
      service.subscribe(DiskListener.new(job:))
      service.subscribe(MkvDiskLoadListener.new(job:))
    end.call
  end
end
