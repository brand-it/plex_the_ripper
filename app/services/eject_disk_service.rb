# frozen_string_literal: true

class EjectDiskService
  extend Dry::Initializer
  include Shell
  include Wisper::Publisher

  param :disk, Types.Instance(Disk)

  def self.call(...)
    new(...).call
  end

  def call
    broadcast(:disk_ejecting)
    eject!
    disk.update!(ejected: true)
    disk.disk_titles.not_ripped.destroy_all
    Disk.ejected.destroy_all
    broadcast(:disk_ejected)
  rescue StandardError => e
    broadcast(:disk_eject_failed, e)
  end

  private

  def eject!
    if OS.mac?
      system!("drutil eject #{disk.disk_name}")
    elsif OS.posix?
      system("eject #{disk.disk_name}")
    elsif OS.windows?
      raise "can't eject disk on windows currently please eject manully"
      # drive_letter = 'D:' # No Idea what the driver letter might be UGH thanks windows
      # system("powershell -command \"(New-Object -com 'WMPlayer.OCX.7').cdromCollection |
      # Where-Object { $_.drive = '#{drive_letter}' } | ForEach-Object { $_.Eject() }\"")
    end
  end
end
