# frozen_string_literal: true

class FindExistingDisksService
  include Shell

  class << self
    delegate :call, to: :new
  end

  def call # rubocop:disable Metrics/MethodLength
    index = 0
    devices.reduce(Disk.not_ejected) do |disks, device|
      if index.zero?
        disks.where(
          name: device.name,
          disk_name: [device.disk_name, device.rdisk_name]
        )
      else
        disks.or(
          Disk.where(
            name: device.name,
            disk_name: [device.disk_name, device.rdisk_name]
          )
        )
      end.tap { index += 1 }
    end
  end
end
