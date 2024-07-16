# frozen_string_literal: true

class CreateDisksService
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  class << self
    delegate :call, to: :new
  end

  def call
    return [] if drives.empty?

    drives.map do |drive|
      Disk.find_or_initialize_by(name: drive.drive_name, disk_name: drive.disc_name)
          .tap do |disk|
        disk.update!(loading: true)
        broadcast_loading!(disk.name)
        disk.disk_titles.each(&:mark_for_destruction)
        disk.disk_info.each do |info|
          disk_title = find_or_build_disk_title(disk, info)
          disk_title.unmark_for_destruction
        end
        disk.update!(loading: false)
      end
    end
  end

  private

  def broadcast_loading!(name = nil)
    component = ProcessComponent.new worker: LoadDiskWorker
    component.with_body { name ? "Loading #{name} ..." : 'Loading the disk ...' }
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def find_or_build_disk_title(disk, title)
    disk.disk_titles.find do |disk_title|
      disk_title.title_id == title.id.to_i &&
        title.filename == disk_title.name &&
        title.size_in_bytes.to_i == disk_title.size &&
        title.duration_seconds.to_i == disk_title.duration
    end || disk.disk_titles.build(
      title_id: title.id,
      name: title.filename,
      size: title.size_in_bytes,
      duration: title.duration_seconds
    )
  end

  def drives
    @drives ||= ListDrivesService.call
  end
end
