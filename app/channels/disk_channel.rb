class DiskChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'disk'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
