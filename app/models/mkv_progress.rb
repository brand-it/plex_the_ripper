# frozen_string_literal: true

# == Schema Information
#
# Table name: mkv_progresses
#
#  id            :integer          not null, primary key
#  completed_at  :datetime
#  failed_at     :datetime
#  name          :string
#  percentage    :float
#  video_type    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  disk_title_id :integer
#  video_id      :integer
#
# Indexes
#
#  index_mkv_progresses_on_disk_title_id            (disk_title_id)
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

  def complete
    assign_attributes(completed_at: Time.current, failed_at: nil, percentage: 100)
  end

  def fail
    assign_attributes(completed_at: nil, failed_at: Time.current, percentage: 0)
  end

  private

  def broadcast_video_progress
    VideoProgressChannel.broadcast_to(
      video,
      ApplicationController.render(VideoProgressComponent.new(video: video))
    )
  end
end
