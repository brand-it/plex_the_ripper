# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id           :integer          not null, primary key
#  byte_size    :bigint           not null
#  checksum     :text
#  content_type :string           not null
#  filename     :string           not null
#  key          :string           not null
#  metadata     :text
#  optimized    :boolean          default(FALSE), not null
#  service_name :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  episode_id   :bigint
#  video_id     :integer
#
# Indexes
#
#  index_video_blobs_on_key_and_service_name  (key,service_name) UNIQUE
#  index_video_blobs_on_video                 (video_id)
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

  VIDEO_FORMATS = [
    '.avi', '.mp4', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.mpeg',
    '.mpg', '.3gp', '.m4v', '.swf', '.rm', '.vob',
    '.ogv', '.ts', '.f4v', '.divx', '.asf', '.mts', '.m2ts', '.dv',
    '.mxf', '.f4p', '.gxf', '.m2v', '.yuv', '.amv',
    '.svi', '.nsv'
  ].freeze
  MOVIE_MATCHER_WITH_YEAR = /(?<title>.*)[(](?<year>\d{4})[)]/
  MOVIE_MATCHER = /(?<title>.*)/
  # TODO: Currently not activly used but these are the patterns we are looking for
  TV_SHOW_SEASON_EPISODE = /[sS](?<season>\d+)[eE](?<episode>\d+)/
  TV_SHOW_MATCHER_FULL = /(?<title>.*)\s\((?<year>.*)\)\s-\s#{TV_SHOW_SEASON_EPISODE}\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_EP_NAME = /(?<title>.*)\s\((?<year>.*)\)\s-\s#{TV_SHOW_SEASON_EPISODE}\s-\s(?<date>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_DATE = /(?<title>.*)\s\((?<year>.*)\)\s-\s#{TV_SHOW_SEASON_EPISODE}\s-\s(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_NUMBER = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_YEAR = /(?<title>.*)\s-\s#{TV_SHOW_SEASON_EPISODE}\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_NUMBER_ONLY = /#{TV_SHOW_SEASON_EPISODE}\.*#{Regexp.union(VIDEO_FORMATS)}/
  belongs_to :video, optional: true
  belongs_to :episode, optional: true

  scope :optimized, -> { where(optimized: true) }
  scope :checksum, -> { where.not(checksum: nil) }
  scope :missing_checksum, -> { where(checksum: nil) }

  delegate :title, :year, :episode, :season, to: :parsed, allow_nil: true

  def tv_show?
    return false if Config::Plex.newest&.tv_path.blank?

    key&.starts_with?(Config::Plex.newest.tv_path) || false
  end

  def movie?
    return false if Config::Plex.newest&.movie_path.blank?

    key&.starts_with?(Config::Plex.newest.movie_path) || false
  end

  private

  def parsed
    if movie?
      parsed_movie
    elsif tv_show?
      parsed_tv_show
    end
  end

  def parsed_tv_show
    return @parsed_tv_show if @parsed_tv_filename

    match = (filename.match(TV_SHOW_MATCHER_FULL) ||
            filename.match(TV_SHOW_WITHOUT_EP_NAME) ||
            filename.match(TV_SHOW_WITHOUT_DATE) ||
            filename.match(TV_SHOW_WITHOUT_NUMBER) ||
            filename.match(TV_SHOW_WITHOUT_YEAR) ||
            filename.match(TV_SHOW_NUMBER_ONLY)
            )&.named_captures || {}

    dir_match = (directory_name.match(MOVIE_MATCHER_WITH_YEAR) ||
                directory_name.match(MOVIE_MATCHER)
                )&.named_captures || {}

    @parsed_tv_show = TvShow.new(
      match['title'] || dir_match['title'],
      (match['year'] || dir_match['year'])&.to_i,
      match['season']&.to_i,
      match['episode']&.to_i
    )
  end

  def parsed_movie
    return @parsed_movie if @parsed_movie

    match = (filename.match(MOVIE_MATCHER_WITH_YEAR) ||
            filename.match(MOVIE_MATCHER) ||
            directory_name.match(MOVIE_MATCHER_WITH_YEAR) ||
            directory_name.match(MOVIE_MATCHER))&.named_captures || {}
    return @parsed_movie = Movie.new(nil, nil) if match.nil?

    @parsed_movie = Movie.new(match['title'], match['year']&.to_i)
  end

  def directory_name
    return '' if key.blank?

    path = movie? ? Config::Plex.newest.movie_path : Config::Plex.newest.tv_path
    @directory_name ||= key.gsub("#{path}/", '').split('/').first.to_s
  end
end
