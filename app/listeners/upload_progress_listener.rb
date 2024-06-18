# frozen_string_literal: true

class UploadProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  option :completed, Types::Integer.optional, default: -> { 0 }
  option :title, Types::String.optional, default: -> { 'Uploading Video' }
  option :message, Types::String.optional, default: -> { '' }
  option :file_size, Types::Integer

  def call(chunk_size: nil)
    @completed += chunk_size
    return if next_update.future? && percentage < 100

    update_component
    @next_update = nil # clear next_update timer
  end

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
        completed: percentage,
        status: :info,
        message: title
      ), layout: false
    )
    component = ProcessComponent.new(worker: UploadWorker)
    component.with_body { progress_bar }
    component
  end

  def percentage
    completed / file_size.to_f * 100
  end

  def next_update
    @next_update ||= 1.second.from_now
  end
end
