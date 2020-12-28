# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def call
    Disk.destroy_all
    ListDrivesService.new.results.map do |drive|
      Disk.new(name: drive.disc_name, disk_name: drive.drive_name).tap do |disk|
        disk.subscribe(DiskProgressListener.new)
        disk.save!
        disk.load_titles!
      end
    end
  end
end
