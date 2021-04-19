# frozen_string_literal: true

class CreateDisksService
  class << self
    def call
      new.call
    end
  end

  def call
    return [] if drives.empty?

    drives.map do |drive|
      Disk.find_or_initialize_by(name: drive.disc_name) do |disk|
        disk.update!(disk_name: drive.drive_name)
        disk.create_titles(disk) if disk.disk_titles.empty?
      end
    end
  end

  private

  def create_titles(disk)
    DiskInfoService.new(disk_name: name).results.each do |title|
      disk.disk_titles.create!(
        title_id: title.id,
        name: title.file_name,
        size: title.size,
        duration: title.duration_seconds
      )
    end
  end

  def drives
    @drives ||= ListDrivesService.results
  end
end
