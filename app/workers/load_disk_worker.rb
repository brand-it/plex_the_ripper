# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def perform
    cable_ready[DiskTitleChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def component
    component = ProcessComponent.new(worker: ScanPlexWorker)
    component.with_body { disks.map(&:name).join(', ') }
    component
  end

  def disks
    @disks ||= FindExistingDisksService.call.presence || CreateDisksService.call
  end
end
