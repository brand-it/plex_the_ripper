# frozen_string_literal: true

class EjectDiskService
  extend Dry::Initializer
  include Shell
  include CableReady::Broadcaster
  delegate :render, to: :ApplicationController

  param :disk, Types.Instance(Disk)

  def self.call(...)
    new(...).call
  end

  def call
    broadcasting("Ejecting Disk #{disk.name}")
    eject!
    broadcasting("Disk Ejected #{disk.name} - Ready for new disk")
  rescue StandardError => e
    broadcasting(e.message)
  end

  private

  def eject!
    if OS.mac?
      system!("drutil eject #{disk_name}")
    elsif OS.posix?
      system("eject #{disk_name}")
    elsif OS.windows?
      raise "can't eject #{disk.name} on windows currently please eject manully"
      # drive_letter = 'D:' # No Idea what the driver letter might be UGH thanks windows
      # system("powershell -command \"(New-Object -com 'WMPlayer.OCX.7').cdromCollection |
      # Where-Object { $_.drive = '#{drive_letter}' } | ForEach-Object { $_.Eject() }\"")
    end
  end

  def disk_name
    disk.disk_name
  end

  def broadcasting(message) # rubocop:disable Metrics/MethodLength
    progress_bar = render(
      ProgressBarComponent.new(
        model: Video,
        completed: 100,
        status: :success,
        message:
      ), layout: false
    )
    component = ProcessComponent.new(worker: RipWorker)
    component.with_body { progress_bar }
    cable_ready[BroadcastChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end
end
