# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def enqueue?
    existing_disks.nil?
  end

  def perform
    cable_ready[DiskTitleChannel.channel_name].reload if existing_disks.nil? && disks.present?
    cable_ready.broadcast
  end

  def disks
    @disks ||= existing_disks || CreateDisksService.call
  end

  def existing_disks
    return @existing_disks if defined?(@existing_disks)

    @existing_disks = FindExistingDisksService.call.presence
  end
end
