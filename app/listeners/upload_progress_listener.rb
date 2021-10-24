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
    return if next_update.future?

    update_component
    @next_update = nil # clear next_update timer
  end

  def update_component
    cable_ready[DiskTitleChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def component
    ProgressBarComponent.new \
      model: DiskTitle,
      completed: percentage,
      status: :info,
      message: title
  end

  def percentage
    completed / file_size.to_f * 100
  end

  def next_update
    @next_update ||= Time.current + 0.5
  end
end
