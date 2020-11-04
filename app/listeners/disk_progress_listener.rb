# frozen_string_literal: true

class DiskProgressListener
  include CableReady::Broadcaster
  delegate :render, to: ApplicationController

  def drives_loaded(drives)
    broadcast ProgressBarComponent.new(label: Disk.model_name.name, completed: 25)
  end

  def disk_titles_loaded(_titles)
    broadcast ProgressBarComponent.new(label: Disk.model_name.name, completed: 50)
  end

  private

  def broadcast(component)
    cable_ready[DiskChannel.channel_name].morph(selector: component.id, html: render(component))
  end
end
