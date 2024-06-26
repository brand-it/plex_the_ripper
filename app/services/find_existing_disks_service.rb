# frozen_string_literal: true

class FindExistingDisksService
  MOUNT_LINE = %r{\A(?<disk_name>\S+)\son\s(?:/Volumes/|)(?<name>.*)\s[(]}
  Device = Struct.new(:name, :disk_name) do
    def rdisk_name
      disk_name.gsub('/dev/', '/dev/r')
    end
  end

  class << self
    delegate :call, to: :new
  end

  # example line:
  # /dev/disk4 on /Volumes/PLANET51 (udf, local, nodev, nosuid, read-only, noowners)
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

  private

  def devices
    @devices ||= `mount`.each_line.filter_map do |line|
      next unless line.start_with?('/dev/')

      match = line.match(MOUNT_LINE)
      Device.new(match[:name], match[:disk_name])
    end
  end
end
