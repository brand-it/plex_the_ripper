# frozen_string_literal: true

class UploadProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  option :completed, Types::Integer.optional, default: -> { 0 }
  option :title, Types::String.optional, default: -> { 'Uploading Video' }
  option :message, Types::String.optional, default: -> { '' }

  def call(percentage)
    component = ProgressBarComponent.new(
      model: DiskTitle,
      completed: @completed = percentage, status: :info, message: title
    )
    cable_ready[DiskTitleChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end
end
