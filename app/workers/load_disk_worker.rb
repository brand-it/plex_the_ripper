# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def perform
    cable_ready[DiskTitleChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready[DiskTitleChannel.channel_name].reload if existing_disks.nil?
    cable_ready.broadcast
  end

  def component
    component = ProcessComponent.new(worker: ScanPlexWorker)
    component.with_body { disks.map(&:name).join(', ') }
    component
  end

  def disks
    @disks ||= existing_disks || CreateDisksService.call
  end

  def existing_disks
    return @existing_disks if defined?(@existing_disks)

    @existing_disks = FindExistingDisksService.call.presence
  end
end
