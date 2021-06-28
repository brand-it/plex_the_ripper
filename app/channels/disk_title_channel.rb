# frozen_string_literal: true

class DiskTitleChannel < ApplicationCable::Channel
  def subscribed
    stream_from channel_name
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
