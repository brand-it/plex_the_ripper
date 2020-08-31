# frozen_string_literal: true

class DisksController < ApplicationController
  def reload
    Disk.delete_all
    LoadDiskJob.perform
    render DiskCardComponent.new(disks: [])
  end
end
