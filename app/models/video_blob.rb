# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id                :integer          not null, primary key
#  byte_size         :bigint           not null
#  checksum          :text
#  content_type      :string           not null
#  extra_type        :integer          default("feature_films")
#  extra_type_number :integer          not null
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
  Movie = Struct.new(:title, :year) do
    def season
      nil
    end

    def episode
      nil
    end
  end
  TvShow = Struct.new(:title, :year, :season, :episode)
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
  VIDEO_FORMATS = [
    '.avi', '.mp4', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.mpeg',
    '.mpg', '.3gp', '.m4v', '.swf', '.rm', '.vob',
    '.ogv', '.ts', '.f4v', '.divx', '.asf', '.mts', '.m2ts', '.dv',
    '.mxf', '.f4p', '.gxf', '.m2v', '.yuv', '.amv',
    '.svi', '.nsv'
  ].freeze
  TITLE_MATCHER = /(?<title>.*)/
  MATCHER_WITH_YEAR = /#{TITLE_MATCHER}[(](?<year>\d{4})[)]/

  # TODO: Currently not activly used but these are the patterns we are looking for
  TV_SHOW_SEASON_EPISODE = /[sS](?<season>\d+)[eE](?<episode>\d+)/
  TV_SHOW_MATCHER_FULL = /#{MATCHER_WITH_YEAR}.*-\s+#{TV_SHOW_SEASON_EPISODE}\s+-\s+(?<date>.*)\s+-\s+(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_EP_NAME = /#{MATCHER_WITH_YEAR}.*-\s+#{TV_SHOW_SEASON_EPISODE}\s+-\s+(?<date>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_DATE = /#{MATCHER_WITH_YEAR}.*-\s+#{TV_SHOW_SEASON_EPISODE}\s+-\s+(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_NUMBER = /#{MATCHER_WITH_YEAR}.*-\s+(?<date>.*)\s+-\s+(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_YEAR = /#{TITLE_MATCHER}.*-\s+#{TV_SHOW_SEASON_EPISODE}\s+-\s+(?<date>.*)\s+-\s+(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_NUMBER_ONLY = /#{TV_SHOW_SEASON_EPISODE}\.*#{Regexp.union(VIDEO_FORMATS)}/

  enum :extra_type, EXTRA_TYPES.keys

  belongs_to :video
  belongs_to :episode, optional: true
  has_many :disk_titles, dependent: :nullify

  scope :checksum, -> { where.not(checksum: nil) }
  scope :missing_checksum, -> { where(checksum: nil) }
  scope :optimized, -> { where(optimized: true) }
  scope :uploadable, -> { where(uploadable: true, uploaded_on: nil) }
  scope :uploaded, -> { where(uploadable: false).where.not(uploaded_on: nil) }
  scope :uploaded_recently, -> { where(arel_table[:uploaded_on].gteq(10.minutes.ago)) }

  delegate :title, :year, :episode, :season, to: :parsed, allow_nil: true, prefix: true
  delegate :plex_name, to: :video, prefix: true, allow_nil: true
  delegate :plex_name, to: :episode, prefix: true, allow_nil: true

  before_validation :set_defaults

  validates :key, presence: true, uniqueness: { message: ->(blob, _) { "#{blob.key} has already been taken" } }

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
    video&.tv? || key_tv_show?
  end

  def movie?
    video&.movie? || key_movie?
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
      video_plex_name
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
      video_plex_name
    elsif video&.tv?
      "#{video_plex_name}/#{episode.season.season_name}"
    end
  end

  def extra_type_directory
    EXTRA_TYPES[extra_type][:dir_name]
  end

  def parsed
    if key_movie?
      parsed_movie
    elsif key_tv_show?
      parsed_tv_show
    end
  end

  def key_movie?
    return false if Config::Plex.newest&.movie_path.blank?

    key&.starts_with?(Config::Plex.newest.movie_path) || false
  end

  def key_tv_show?
    return false if Config::Plex.newest&.tv_path.blank?

    key&.starts_with?(Config::Plex.newest.tv_path) || false
  end

  def parsed_tv_show
    return @parsed_tv_show if @parsed_tv_filename

    match = (filename.match(TV_SHOW_WITHOUT_DATE) ||
             filename.match(TV_SHOW_MATCHER_FULL) ||
            filename.match(TV_SHOW_WITHOUT_EP_NAME) ||
            filename.match(TV_SHOW_WITHOUT_NUMBER) ||
            filename.match(TV_SHOW_WITHOUT_YEAR) ||
            filename.match(TV_SHOW_NUMBER_ONLY)
            )&.named_captures || {}

    dir_match = (directory_name.match(MATCHER_WITH_YEAR) ||
                directory_name.match(TITLE_MATCHER)
                )&.named_captures || {}

    @parsed_tv_show = TvShow.new(
      dir_match['title'] || match['title'],
      (dir_match['year'] || match['year'])&.to_i,
      match['season']&.to_i,
      match['episode']&.to_i
    )
  end

  def parsed_movie
    return @parsed_movie if @parsed_movie

    match = (
      directory_name.match(MATCHER_WITH_YEAR) ||
             directory_name.match(TITLE_MATCHER) ||
             filename.match(MATCHER_WITH_YEAR) ||
             filename.match(TITLE_MATCHER)
    )&.named_captures || {}
    return @parsed_movie = Movie.new(nil, nil) if match.nil?

    @parsed_movie = Movie.new(match['title'], match['year']&.to_i)
  end

  def directory_name
    return '' if key.blank?

    @directory_name ||= key.gsub("#{plex_root_path}/", '').split('/').first.to_s
  end

  def convert_to_extra_type
    return '' if key.blank?

    @convert_to_extra_type ||= key.gsub("#{video_path}/", '').split('/').first.to_s
  end

  def plex_root_path
    raise 'plex config is missing and is required' if Config::Plex.newest.nil?

    key_movie? || video&.movie? ? Config::Plex.newest.movie_path : Config::Plex.newest.tv_path
  end

  def video_path
    "#{plex_root_path}/#{directory_name}"
  end

  def set_defaults
    set_extra_type_from_key
    set_extra_type_number
    self.filename ||= plex_name.to_s
    self.key ||= plex_path.to_s
    self.content_type ||= 'video/x-matroska'
    self.byte_size ||= 0
  end

  def set_extra_type_from_key
    return unless feature_films?

    self.extra_type = match_extra_type_by_dir(key) ||
                      EXTRA_TYPES.first.first
  end

  def match_extra_type_by_dir(name)
    return if name.blank?

    VideoBlob::EXTRA_TYPES.find { name.include?(_1[1][:dir_name]) }&.first
  end

  def set_extra_type_number
    return if extra_type_number

    self.extra_type_number = VideoBlob.where(video:, extra_type:).pluck(:extra_type_number).max.to_i + 1
  end
end
