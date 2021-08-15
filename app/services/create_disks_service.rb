# frozen_string_literal: true

class CreateDisksService
  class << self
    delegate :call, to: :new
  end

  def call
    return [] if drives.empty?

    drives.map do |drive|
      Disk.find_or_initialize_by(name: drive.drive_name, disk_name: drive.disc_name).tap do |disk|
        disk.disk_info.each { |title| update_disk_title(disk, title) }
        disk.save!
      end
    end
  end

  private

  def update_disk_title(disk, title)
    disk_title = find_or_build_disk_title(disk, title)
    disk_title.assign_attributes name: title.filename,
                                 size: title.size_in_bytes,
                                 duration: title.duration_seconds
  end

  def find_or_build_disk_title(disk, title)
    disk.disk_titles.find { |t| t.title_id == title.id } ||
      disk.disk_titles.build(title_id: title.id)
  end

  def drives
    @drives ||= ListDrivesService.results
  end
end
