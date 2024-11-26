# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  include Shell
  def enqueue?
    Disk.not_ejected.count != devices.count(&:optical?)
  end

  def perform
    Disk.where
        .not(id: Disk.verified_disks.select(:id))
        .includes(:disk_titles)
        .in_batches
        .destroy_all
    DiskTitle.not_ripped.in_batches.destroy_all
    mkv_disk_load_listener = MkvDiskLoadListener.new(job:)
    CreateDisksService.new(listener: mkv_disk_load_listener).tap do |service|
      service.subscribe(DiskListener.new(job:))
      service.subscribe(mkv_disk_load_listener)
    end.call
  end
end
