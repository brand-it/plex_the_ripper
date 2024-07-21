# frozen_string_literal: true

class CreateDisksService < ApplicationService
  include Shell

  def call
    return [] if (drives = list_drives).empty?

    drives.map do |drive|
      Disk.find_or_initialize_by(name: drive.drive_name, disk_name: drive.disc_name)
          .tap do |disk|
        disk.update!(loading: true)
        broadcast(:loading)
        disk.disk_titles.each(&:mark_for_destruction)
        disk.disk_info.each do |info|
          disk_title = find_or_build_disk_title(disk, info)
          disk_title.unmark_for_destruction
        end
        disk.update!(loading: false)
      end
    end
  end

  private

  def existing_disks
    index = 0
    devices.reduce(Disk.not_ejected) do |disks, device|
      if index.zero?
        disks.where(
          name: device.drive_name,
          disk_name: [device.disc_name, device.rdisk_name]
        )
      else
        disks.or(
          Disk.not_ejected.where(
            name: device.drive_name,
            disk_name: [device.disc_name, device.rdisk_name]
          )
        )
      end.tap { index += 1 }
    end
  end

  def broadcast_loading!(name = nil)

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
