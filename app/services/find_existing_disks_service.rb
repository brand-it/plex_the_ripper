# frozen_string_literal: true

class FindExistingDisksService
  class << self
    delegate :call, to: :new
  end

  def call # rubocop:disable Metrics/MethodLength
    index = 0
    devices.reduce(Disk.not_ejected) do |disks, device|
      if index.zero?
        disks.where(
          name: device.drive_name,
          disk_name: device.disc_name
        )
      else
        disks.or(
          Disk.where(
            name: device.drive_name,
            disk_name: device.disc_name
          )
        )
      end.tap { index += 1 }
    end
  end

  def devices
    @devices ||= ListDrivesService.call
  end
end
