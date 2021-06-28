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

  # def update_progress(completed, message: nil, status: :info)
  #   component = ProgressBarComponent.new(
  #     model: Disk,
  #     completed: completed, status: status, message: message
  #   )
  #   cable_ready[DiskChannel.channel_name].morph(
  #     selector: "##{component.dom_id}",
  #     html: render(component, layout: false)
  #   )
  #   cable_ready.broadcast
  # end
end
