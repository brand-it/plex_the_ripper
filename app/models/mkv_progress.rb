# frozen_string_literal: true

# == Schema Information
#
# Table name: mkv_progresses
#
#  id           :integer          not null, primary key
#  completed_at :datetime
#  failed_at    :datetime
#  name         :string
#  percentage   :float
#  video_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  video_id     :integer
#
# Indexes
#
#  index_mkv_progresses_on_video_type_and_video_id  (video_type,video_id)
#
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
