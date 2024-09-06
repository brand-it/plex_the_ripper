# frozen_string_literal: true

class CreateDisksService < ApplicationService
  include Shell

  option :job, Types.Instance(Job)

  def call
    return [] if (drives = list_drives).empty?

    drives.map { create_or_update_disks(_1) }
  end

  private

  def create_or_update_disks(drive)
    find_or_initalize_disk(drive).tap do |disk|
      disk.update!(loading: true)
      broadcast(:disk_loading, disk)
      disk.disk_titles.each(&:mark_for_destruction)
      find_or_build_disk_titles(disk)
      disk.update!(ejected: false)
      broadcast(:disk_loaded, disk)
    ensure
      disk.update!(loading: false)
    end
  end

  def find_or_build_disk_titles(disk)
    disk_info(disk).each do |info|
      disk_title = find_or_build_disk_title(disk, info)
      disk_title.unmark_for_destruction
    end
  end

  def find_or_initalize_disk(drive)
    Disk.find_or_initialize_by(name: drive.drive_name, disk_name: drive.disc_name)
  end

  def disk_info(disk)
    service = DiskInfoService.new(disk_name: disk.disk_name)
    service.subscribe(MkvDiskLoadListener.new(job:))
    service.call
  end

  def find_or_build_disk_title(disk, title)
    disk.disk_titles.find do |disk_title|
      disk_title.title_id == title.id.to_i &&
        title.filename == disk_title.name &&
        title.size_in_bytes.to_i == disk_title.size &&
        title.duration_seconds.to_i == disk_title.duration
    end || disk.disk_titles.build(
      title_id: title.id,
      name: title.filename,
      size: title.size_in_bytes,
      duration: title.duration_seconds
    )
  end
end
