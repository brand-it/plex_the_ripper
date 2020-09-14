# frozen_string_literal: true

class DisksController < ApplicationController
  def reload
    Disk.delete_all
    LoadDiskJob.perform
    Disk.all_valid?
    render DiskCardComponent.new(disks: [])
  end

  def create
    CreateMovieJob.perform
  end
end
