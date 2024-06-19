# frozen_string_literal: true

class UploadWorker < ApplicationWorker
  option :disk_title_id, Types::Integer
  attr_reader :disk_title

  def perform
    @disk_title = DiskTitle.find(disk_title_id)
    progress_listener = UploadProgressListener.new(
      title: "Uploading #{disk_title.video.title}",
      file_size: disk_title.size
    )
    Ftp::UploadMkvService.call(disk_title:, progress_listener:)
    update_component
  end

  private

  def update_component
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def component # rubocop:disable Metrics/MethodLength
    progress_bar = render(
      ProgressBarComponent.new(
        model: Video,
        completed: 100,
        status: :success,
        message: "Finished Uploading #{disk_title.video.title}"
      ), layout: false
    )
    component = ProcessComponent.new(worker: UploadWorker)
    component.with_body { progress_bar }
    component
  end
end
