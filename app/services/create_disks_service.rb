# frozen_string_literal: true

class CreateDisksService < ApplicationService
  include Shell

  option :listener, optional: true

  def call
    return [] if (drives = list_drives).empty?

    drives.map { create_or_update_disks(_1) }
  end

  private

  def create_or_update_disks(drive)
    find_or_initialize_disk(drive).tap do |disk|
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
      Rails.logger.debug { "found #{disk_title.to_label} " }
      disk_title.unmark_for_destruction
    end
  end

  def find_or_initialize_disk(drive)
    Disk.find_or_initialize_by(name: drive.drive_name, disk_name: drive.disc_name).tap do |disk|
      disk.disk_titles.load
    end
  end

  def disk_info(disk)
    service = DiskInfoService.new(disk_name: disk.disk_name)
    service.subscribe(listener) if listener
    service.call
  end

  def find_or_build_disk_title(disk, title)
    disk.disk_titles.find do |disk_title|
      disk_title.title_id == title.id &&
        title.name == disk_title.name &&
        title.filename == disk_title.filename &&
        title.bytes == disk_title.size &&
        title.duration_seconds == disk_title.duration &&
        title.angle == disk_title.angle &&
        title.description == disk_title.description &&
        title.segment_map == disk_title.segment_map
    end || disk.disk_titles.build(
      title_id: title.id,
      name: title.name,
      filename: title.filename,
      size: title.bytes,
      duration: title.duration_seconds,
      angle: title.angle,
      description: title.description,
      segment_map: title.segment_map
    )
  end
end
