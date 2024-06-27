# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  duration        :integer
#  name            :string           not null
#  size            :integer          default(0), not null
#  video_type      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  episode_id      :integer
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_type,video_id)
#
class DiskTitle < ApplicationRecord
  include ActionView::Helpers::DateHelper

  belongs_to :video, polymorphic: true, optional: true
  belongs_to :episode, optional: true
  belongs_to :disk

  def to_label
    "##{title_id} #{name} #{distance_of_time_in_words(duration.seconds)}"
  end

  def tmp_plex_path
    require_movie_or_episode!
    video.is_a?(Tv) ? episode.tmp_plex_path : video.tmp_plex_path
  end

  def plex_path
    require_movie_or_episode!
    video.is_a?(Tv) ? episode.plex_path : video.plex_path
  end

  def plex_name
    require_movie_or_episode!
    video.is_a?(Tv) ? episode.plex_name : video.plex_name
  end

  def tmp_plex_dir
    require_movie_or_episode!
    video.is_a?(Tv) ? episode.tmp_plex_dir : video.tmp_plex_dir
  end

  def tmp_plex_path_exists?
    return false if video.nil?

    video.is_a?(Tv) ? episode.tmp_plex_path_exists? : video.tmp_plex_path_exists?
  end

  def require_movie_or_episode!
    return if video.is_a?(Movie)
    return if video.is_a?(Tv) && episode

    raise 'requires episode or movie to rip'
  end
end
