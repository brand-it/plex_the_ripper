# frozen_string_literal: true

class UploadProgressListener
  extend Dry::Initializer
  include SlackUtility
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  option :video_blob, Types.Instance(::VideoBlob)
  option :file_size, Types::Integer
  attr_reader :completed

  def update_progress(chunk_size: nil)
    @completed ||= 0
    @completed += chunk_size
    return if next_update.future?

    update_component
    @next_update = nil # clear next_update timer
  end

  def start
    update_component
  end

  def finished
    @completed = file_size
    update_component
  end

  private

  def component # rubocop:disable Metrics/MethodLength
    progress_bar = render(
      ProgressBarComponent.new(
        model: Video,
        completed: percentage,
        status: percentage < 100 ? :info : :success,
        message: video_blob.title
      ), layout: false
    )
    component = ProcessComponent.new(worker: UploadWorker)
    component.with_body { progress_bar }
    component
  end

  def update_component
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def percentage
    (@completed.to_i / file_size.to_f) * 100
  end

  def next_update
    @next_update ||= 1.second.from_now
  end
end
