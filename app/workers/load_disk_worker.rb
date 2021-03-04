# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    Disk.destroy_all
    return update_progress(100, message: 'Could not load disk', status: :danger) if drives.empty?

    drives.map do |drive|
      update_progress(50, message: "Loading titles for #{drive.drive_name}")
      Disk.create!(name: drive.disc_name, disk_name: drive.drive_name).tap do |disk|
        disk.load_titles!
        disk.save!
      end
    end
    update_progress(100, message: 'Ready', status: :success)
  rescue StandardError => e
    update_progress(100, message: e.message, status: :danger)
    raise e
  end

  def drives
    @drives ||= ListDrivesService.new.results
  end

  def update_progress(completed, message: nil, status: :info)
    component = ProgressBarComponent.new(
      label: Disk.model_name.name,
      completed: completed, status: status, message: message
    )
    cable_ready[DiskChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end
end
