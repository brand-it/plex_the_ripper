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
        disk.disk_info.each { update_disk_title(disk, _1) }
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

  def update_disk_title(disk, title)
    disk_title = find_or_build_disk_title(disk, title)
    disk_title.assign_attributes name: title.filename,
                                 size: title.size_in_bytes,
                                 duration: title.duration_seconds
  end

  def find_or_build_disk_title(disk, title)
    disk.not_ripped_disk_titles.find { |t| t.title_id == title.id } ||
      disk.not_ripped_disk_titles.build(title_id: title.id)
  end

  def drives
    @drives ||= ListDrivesService.call
  end
end
