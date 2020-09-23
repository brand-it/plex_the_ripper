# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def call
    broadcast(in_progress: true)
    disks
    broadcast(in_progress: true)
    create_disk_titles
    broadcast(in_progress: false)
  end

  private

  def create_disk_titles
    disks.each do |disk|
      titles = DiskInfoService.new(disk_name: disk.name).call
      titles.each do |title|
        disk.disk_titles.create!(
          title_id: title.id, name: title.file_name,
          size: title.size.to_f, duration: title.duration_seconds
        )
      end
    end
  end

  def disks
    @disks ||= ListDrivesService.new.call.map do |drive|
      Disk.find_or_initialize_by(name: drive.disc_name).tap do |disk|
        disk.update!(name: drive.disc_name, disk_name: drive.drive_name)
      end
    end
  end

  def broadcast(in_progress:)
    ActionCable.server.broadcast(
      'disk', ApplicationController.render(DiskCardComponent.new(disks: disks, in_progress: in_progress))
    )
  end
end
