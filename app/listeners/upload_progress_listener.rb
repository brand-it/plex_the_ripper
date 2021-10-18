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
    self.completed += chuck_size

    component = ProgressBarComponent.new model: DiskTitle,
                                         completed: percentage,
                                         status: :info,
                                         message: title
    cable_ready[DiskTitleChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end

  def percentage
    completed / file_size.to_f * 100
  end
end
