# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  angle           :integer
#  description     :string
#  duration        :integer
#  filename        :string           not null
#  name            :string
#  ripped_at       :datetime
#  segment_map     :string
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  episode_id      :integer
#  episode_last_id :integer
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#  video_blob_id   :integer
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_episode_last_id  (episode_last_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_id)
#  index_disk_titles_on_video_blob_id    (video_blob_id)
#
class DiskTitle < ApplicationRecord
  include ActionView::Helpers::DateHelper

  serialize :segment_map, coder: JSON, type: Array

  belongs_to :video, optional: true
  belongs_to :episode, optional: true
  belongs_to :episode_last, optional: true, class_name: 'Episode'
  belongs_to :disk, optional: true

  belongs_to :video_blob, optional: true

  scope :not_ripped, -> { where(ripped_at: nil) }
  scope :ripped, -> { where.not(ripped_at: nil) }
  scope :sort_by_segment_map, -> { order(:segment_map) }

  validates :filename, presence: true

  before_save :set_episode_last

  def to_label
    [
      "##{title_id}",
      filename || name,
      distance_of_time_in_words(duration, 0, include_seconds: false, scope: 'datetime.distance_in_words.short'),
      segment_map.join(', ')
    ].compact_blank.join(' ')
  end

  def episode_numbers
    return if episode.nil?

    episode.episode_number..(episode_last&.episode_number || episode.episode_number)
  end

  private

  def set_episode_last
    self.episode_last = nil if episode.nil?
    self.episode_last ||= episode
  end
end
