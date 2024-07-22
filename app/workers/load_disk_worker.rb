# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def enqueue?
    Disk.verified_disks.empty?
  end

  def perform
    Disk.not_ejected.update_all(ejected: true)
    reload_page = disks.any?(&:ejected)
    disks.each { _1.update!(ejected: false) }
    reload_page ? broadcast_reload! : broadcast_no_disk_found!
  end

  def disks
    @disks ||= CreateDisksService.new.tap do |service|
      service.subscribe(DiskListener.new)
    end.call
  end

  def broadcast_reload!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end

  def broadcast_no_disk_found!
    component = LoadDiskProcessComponent.new
    broadcast(component)
  end

  def broadcast(component)
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end
end
