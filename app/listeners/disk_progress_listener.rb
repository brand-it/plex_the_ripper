# frozen_string_literal: true

class DiskProgressListener
  include CableReady::Broadcaster
  delegate :render, to: ApplicationController

  def disk_updated(_disk)
    component = ProgressBarComponent.new(
      label: Disk.model_name.name,
      completed: Disk.percentage_completed
    )
    cable_ready[DiskChannel.channel_name].replace(
      selector: component.dom_id,
      html: render(component)
    )
    cable_ready.broadcast
  end
end
