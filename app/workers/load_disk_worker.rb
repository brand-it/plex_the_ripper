# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def call
    disks.each do |disk|
      disk_info(disk.name).results.each do |title|
        disk.disk_titles.create!(
          title_id: title.id,
          name: title.file_name,
          size: title.size,
          duration: title.duration_seconds
        )
      end
    end
  end

  private

  def disks
    @disks ||= list_disks.results.map do |drive|
      Disk.find_or_initialize_by(name: drive.disc_name).tap do |disk|
        disk.update!(name: drive.disc_name, disk_name: drive.drive_name)
      end
    end
  end

  def list_disks
    @list_disks ||= ListDrivesService.new
  end

  def disk_info(disk_name)
    DiskInfoService.new(disk_name: disk_name).tap do |info|
      info.subscribe(DiskProgressListener.new)
    end
  end
end
