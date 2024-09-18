# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id                :integer          not null, primary key
#  byte_size         :bigint           not null
#  checksum          :text
#  content_type      :string           not null
#  edition           :string
#  extra_type        :integer          default("feature_films")
#  extra_type_number :integer
#  filename          :string           not null
#  key               :string           not null
#  metadata          :text
#  optimized         :boolean          default(FALSE), not null
#  uploadable        :boolean          default(FALSE), not null
#  uploaded_on       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  episode_id        :bigint
#  video_id          :integer
#
# Indexes
#
#  idx_on_extra_type_number_video_id_extra_type_1978193db6  (extra_type_number,video_id,extra_type) UNIQUE
#  index_video_blobs_on_key                                 (key) UNIQUE
#  index_video_blobs_on_key_and_service_name                (key) UNIQUE
#  index_video_blobs_on_video                               (video_id)
#
class VideoBlob < ApplicationRecord
  # Sort order is important don't change...
  EXTRA_TYPES = {
    feature_films: { dir_name: 'Feature Films' },
    behind_the_scenes: { dir_name: 'Behind The Scenes' },
    deleted_scenes: { dir_name: 'Deleted Scenes' },
    featurettes: { dir_name: 'Featurettes' },
    interviews: { dir_name: 'Interviews' },
    scenes: { dir_name: 'Scenes' },
    shorts: { dir_name: 'Shorts' },
    trailers: { dir_name: 'Trailers' },
    other: { dir_name: 'Other' }
  }.with_indifferent_access

  enum :extra_type, EXTRA_TYPES.keys

  belongs_to :video
  belongs_to :episode, optional: true
  has_many :disk_titles, dependent: :nullify

  scope :checksum, -> { where.not(checksum: nil) }
  scope :missing_checksum, -> { where(checksum: nil) }
  scope :optimized, -> { where(optimized: true) }
  scope :uploadable, -> { where(uploadable: true) }
  scope :not_uploaded, -> { where.not(uploaded_on: nil) }
  scope :uploaded, -> { where(uploadable: false).not_uploaded }
  scope :uploaded_recently, -> { where(arel_table[:uploaded_on].gteq(10.minutes.ago)) }

  delegate(
    :content_type,
    :edition,
    :episode,
    :extra_number,
    :extra_type,
    :extra,
    :filename,
    :optimized,
    :plex_version,
    :season,
    :title,
    :type,
    :year,
    to: :parsed, allow_nil: true, prefix: true
  )
  delegate :plex_name, to: :video, prefix: true, allow_nil: true
  delegate :plex_name, to: :episode, prefix: true, allow_nil: true

  before_validation :set_defaults
  before_validation :set_edition

  validates :key, presence: true, uniqueness: { message: ->(blob, _) { "#{blob.key} has already been taken" } }
  validates :extra_type, presence: true

  validates :extra_type_number, uniqueness: { scope: %i[video_id extra_type] }, allow_nil: true

  def title
    if video.tv?
      season = episode.season
      "#{video.title} - S#{season.season_number}E#{episode.episode_number} #{episode.name}"
    elsif feature_films?
      video.title
    else
      "#{extra_type.humanize} ##{extra_type_number} #{video.title}"
    end
  end

  def uploaded?
    uploaded_on.present?
  end

  def tv_show?
    video&.tv? || parsed&.tv? || false
  end

  def movie?
    video&.movie? || parsed&.movie? || false
  end

  def plex_path
    if feature_films?
      Pathname.new("#{plex_dir_name}/#{plex_name}.mkv")
    else
      Pathname.new("#{plex_dir_name}/#{extra_type_directory} ##{extra_type_number}.mkv")
    end
  end

  def tmp_plex_path
    if feature_films?
      tmp_plex_dir.join("#{plex_name}.mkv")
    else
      tmp_plex_dir.join("#{extra_type_directory} ##{extra_type_number}.mkv")
    end
  end

  def tmp_plex_dir
    if feature_films?
      Rails.root.join("tmp/#{video.type.parameterize}/#{subdirectories}")
    else
      Rails.root.join("tmp/#{video.type.parameterize}/#{video_plex_name}/#{extra_type_directory}")
    end
  end

  def tmp_plex_path_exists?
    File.exist?(tmp_plex_path)
  end

  def plex_name
    if video&.movie?
      [
        video_plex_name, ("{edition-#{edition}}" if edition.present?)
      ].compact_blank.join(' ')
    elsif video&.tv?
      episode_plex_name
    end
  end

  private

  def plex_dir_name
    if feature_films?
      Pathname.new("#{plex_root_path}/#{subdirectories}")
    else
      Pathname.new("#{plex_root_path}/#{video_plex_name}/#{extra_type_directory}")
    end
  end

  def subdirectories
    if video&.movie?
      [
        video_plex_name, ("{edition-#{edition}}" if edition.present?)
      ].compact_blank.join(' ')
    elsif video&.tv?
      "#{video_plex_name}/#{episode.season.season_name}"
    end
  end

  def extra_type_directory
    EXTRA_TYPES[extra_type][:dir_name]
  end

  def parsed
    @parsed ||= KeyParserService.call(key)
  end

  def plex_root_path
    raise 'plex config is missing and is required' if Config::Plex.newest.nil?

    parsed&.movie? || video&.movie? ? Config::Plex.newest.movie_path : Config::Plex.newest.tv_path
  end

  def video_path
    "#{plex_root_path}/#{directory_name}"
  end

  def set_defaults
    self.filename ||= plex_name.to_s
    self.key ||= plex_path.to_s
    self.content_type ||= 'video/x-matroska'
    self.byte_size ||= 0
  end

  def set_edition
    self.edition = parsed_edition
  end
end
