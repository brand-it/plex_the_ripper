# frozen_string_literal: true

class VideoProgressChannel < ApplicationCable::Channel
  def subscribed
    video = params[:type].constantize.find(params[:video_id])
    stream_for video
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
