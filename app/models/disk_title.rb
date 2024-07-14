# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  duration        :integer
#  name            :string           not null
#  ripped_at       :datetime
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  episode_id      :integer
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#  video_blob_id   :integer
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_id)
#  index_disk_titles_on_video_blob_id    (video_blob_id)
#
class DiskTitle < ApplicationRecord
  include ActionView::Helpers::DateHelper

  belongs_to :video, optional: true
  belongs_to :episode, optional: true
  belongs_to :disk, optional: true

  belongs_to :video_blob, optional: true

  scope :not_ripped, -> { where(ripped_at: nil) }
  scope :ripped, -> { where.not(ripped_at: nil) }

  delegate :tmp_plex_path, :plex_path, :tmp_plex_path_exists?, :tmp_plex_dir, to: :video_blob

  def duration
    super&.seconds
  end

  def to_label
    "##{title_id} #{name} #{distance_of_time_in_words(duration)}"
  end
end
