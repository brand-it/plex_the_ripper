# frozen_string_literal: true

class VideoProgressChannel < ApplicationCable::Channel
  def subscribed
    stream_from channel_name
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
