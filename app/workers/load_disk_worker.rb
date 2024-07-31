# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def enqueue?
    Disk.verified_disks.empty?
  end

  def perform
    Disk.update_all(ejected: true, loading: false)

    CreateDisksService.new(job:).tap do |service|
      service.subscribe(DiskListener.new(job:))
      service.subscribe(MkvDiskLoadListener.new(job:))
    end.call
  end
end
