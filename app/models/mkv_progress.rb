# frozen_string_literal: true

# == Schema Information
#
# Table name: mkv_progresses
#
#  id                :integer          not null, primary key
#  completed_at      :datetime
#  failed_at         :datetime
#  message           :text
#  name              :string
#  percentage        :float
#  progressable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  disk_id           :bigint
#  disk_title_id     :bigint
#  progressable_id   :bigint
#
# Indexes
#
#  index_mkv_progresses_on_disk_id                                (disk_id)
#  index_mkv_progresses_on_disk_title_id                          (disk_title_id)
#  index_mkv_progresses_on_progressable_type_and_progressable_id  (progressable_type,progressable_id)
#
class MkvProgress < ApplicationRecord
  include CableReady::Broadcaster
  delegate :render, to: ApplicationController

  belongs_to :progressable, polymorphic: true
  belongs_to :disk_title, dependent: :destroy
  belongs_to :disk, dependent: :destroy

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
    cable_ready[VideoProgressChannel.channel_name].morph(
      selector: dom_id(video, :progress),
      html: render(VideoProgressComponent.new(video: video))
    )
    cable_ready.broadcast
  end
end
