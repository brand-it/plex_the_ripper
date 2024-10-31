# frozen_string_literal: true

# == Schema Information
#
# Table name: episodes
#
#  id              :integer          not null, primary key
#  air_date        :date
#  episode_number  :integer
#  file_path       :string
#  name            :string
#  overview        :string
#  runtime         :integer
#  still_path      :string
#  workflow_state  :string
#  season_id       :bigint
#  the_movie_db_id :integer
#
# Indexes
#
#  index_episodes_on_season_id  (season_id)
#
class Episode < ApplicationRecord
  include ActionView::Helpers::DateHelper

  belongs_to :season
  has_many :disk_titles, dependent: :nullify
  has_many :ripped_disk_titles, -> { ripped }, class_name: 'DiskTitle', dependent: false, inverse_of: :episode
  has_many :video_blobs, dependent: :nullify
  has_many :uploaded_video_blobs, -> { uploaded }, class_name: 'VideoBlob', dependent: false, inverse_of: :episode

  validates :episode_number, presence: true

  scope :order_by_episode_number, -> { order(:episode_number) }

  delegate :tv, to: :season
  delegate :title, :plex_name, to: :tv, prefix: true
  EPISODE_RUNNTIME_MARGIN = 3.minutes.to_i

  def to_label
    "s#{season.format_season_number}e#{format_episode_number} - #{runtime ? distance_of_time_in_words(runtime) : 'runtime unknown'} - #{name}"
  end

  def runtime_range
    return if runtime.nil?

    @runtime_range ||= (runtime - EPISODE_RUNNTIME_MARGIN)...(runtime + EPISODE_RUNNTIME_MARGIN)
  end

  def plex_name(part: nil, episode_last: nil)
    [
      tv.plex_name,
      [
        "s#{season.format_season_number}e#{format_episode_number}",
        ("e#{episode_last.format_episode_number}" if episode_last && episode_last.id != id)
      ].compact_blank.join('-'),
      part ? "pt#{part}" : name
    ].compact_blank.join(' - ')
  end

  def format_episode_number
    format('%02d', episode_number)
  end
end
