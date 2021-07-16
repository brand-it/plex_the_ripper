# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  option :disk_id, Types::Integer
  def call
    CreateDisksService.call
  end

  private

  def disk
    @disk ||= Disk.find(disk_id)
  end
end
