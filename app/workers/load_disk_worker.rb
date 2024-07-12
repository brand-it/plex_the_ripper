# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def enqueue?
    existing_disks.nil?
  end

  def perform
    Disk.not_ejected.update_all(ejected: true)
    reload_page = disks.any?(&:ejected)
    disks.each { _1.update!(ejected: false) }
    reload_page ? broadcast_reload! : broadcast_no_disk_found!
  end

  def disks
    @disks ||= CreateDisksService.call
  end

  def existing_disks
    return @existing_disks if defined?(@existing_disks)

    @existing_disks = FindExistingDisksService.call.presence
  end

  def broadcast_reload!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end

  def broadcast_no_disk_found!
    component = ProcessComponent.new worker: LoadDiskWorker
    component.with_body { 'No disks found' }
    broadcast(component)
  end

  def broadcast(component)
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end
end
