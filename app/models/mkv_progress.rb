# frozen_string_literal: true

class MkvProgress < ApplicationRecord
  belongs_to :video, polymorphic: true

  after_commit :broadcast_video_progress

  def completed?
    completed_at.present?
  end

  def failed?
    failed_at.present?
  end

  def complete!
    update!(completed_at: Time.current, failed_at: nil)
  end

  def fail!
    update!(completed_at: nil, failed_at: Time.current)
  end

  private

  def broadcast_video_progress
    VideoProgressChannel.broadcast_to(
      video,
      ApplicationController.render(VideoProgressComponent.new(video: video))
    )
  end
end
