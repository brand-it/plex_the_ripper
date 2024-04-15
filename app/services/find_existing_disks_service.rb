# frozen_string_literal: true

class FindExistingDisksService
  MOUNT_LINE = %r{\A(?<disk_name>\S+)\son\s(?:/Volumes/|)(?<name>\S+)}
  class << self
    delegate :call, to: :new
  end

  # example line:
  # /dev/disk4 on /Volumes/PLANET51 (udf, local, nodev, nosuid, read-only, noowners)
  def call
    mounts = `mount`
    disks = []
    mounts.each_line do |line|
      next unless line.start_with?('/dev/')

      match = line.match(MOUNT_LINE)
      rdisk_name = match[:disk_name].gsub('/dev/', '/dev/r')
      disks << Disk.find_by(name: match[:name], disk_name: [match[:disk_name], rdisk_name])
    end
    disks.compact
  end
end
