# frozen_string_literal: true

class LoadDiskJob
  include Concurrent::Async

  class << self
    attr_accessor :loading

    def perform
      return if loading

      self.loading = true
      new.async.load
    end
  end

  def load
    disks
    broadcast
    create_disk_titles
    self.class.loading = false
    broadcast
  end

  private

  def create_disk_titles
    disks.each do |disk|
      titles = DiskInfoService.new(disk_name: disk.name).call
      titles.each do |title|
        disk.disk_titles.create!(
          name: title.file_name,
          size: title.size.to_f,
          duration: title.duration_seconds
        )
      end
    end
  end

  def disks
    @disks ||= ListDrivesService.new.call.map do |drive|
      disk = Disk.find_or_initialize_by(name: drive.disc_name)
      disk.update!(name: drive.disc_name, disk_name: drive.drive_name)
      disk
    end
  end

  def broadcast
    ActionCable.server.broadcast(
      'disk',
      ApplicationController.render(
        DiskCardComponent.new(disks: disks)
      )
    )
  end
end
