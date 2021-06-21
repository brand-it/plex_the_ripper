# frozen_string_literal: true

class CreateDisksService
  class << self
    delegate :call, to: :new
  end

  def call
    return [] if drives.empty?

    drives.map do |drive|
      Disk.find_or_initialize_by(name: drive.drive_name, disk_name: drive.disc_name).tap do |disk|
        disk.disk_titles = []
        disk.disk_info.each do |title|
          disk.disk_titles.build(
            title_id: title.id,
            name: title.file_name,
            size: title.size,
            duration: title.duration_seconds
          )
        end
        disk.save!
      end
    end
  end

  private

  def drives
    @drives ||= ListDrivesService.results
  end
end
