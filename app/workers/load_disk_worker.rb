# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  include Shell
  def enqueue?
    Disk.not_ejected.count != devices.count(&:optical?)
  end

  def perform
    Disk.where
        .not(id: Disk.verified_disks.select(:id))
        .in_batches
        .destroy_all
    DiskTitle.not_ripped.in_batches.destroy_all
    CreateDisksService.new(job:).tap do |service|
      service.subscribe(DiskListener.new(job:))
      service.subscribe(MkvDiskLoadListener.new(job:))
    end.call
  end
end
