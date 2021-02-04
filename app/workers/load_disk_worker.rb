# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker

  def call
    Disk.destroy_all
    sleep 10
    return load_failure if drives.empty?

    drives.map do |drive|
      Disk.new(name: drive.disc_name, disk_name: drive.drive_name).tap do |disk|
        disk.subscribe(DiskProgressListener.new)
        disk.save!
        disk.load_titles!
      end
    end
  end

  def drives
    @drives ||= ListDrivesService.new.results
  end

  def load_failure
    component = ProgressBarComponent.new(
      label: Disk.model_name.name,
      completed: 100,
      status: :danger,
      message: 'Could not load disk'
    )
    cable_ready[DiskChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end
end
