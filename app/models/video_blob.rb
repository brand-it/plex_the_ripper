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
#  video_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  video_id     :integer
#
# Indexes
#
#  index_video_blobs_on_key_and_service_name  (key,service_name) UNIQUE
#  index_video_blobs_on_video                 (video_type,video_id)
#
class VideoBlob < ApplicationRecord
  Movie = Struct.new(:title, :year)
  MOVIE_MATCHER_WITH_YEAR = /(?<title>.*)[(](?<year>\d{4})[)]/
  MOVIE_MATCHER = /(?<title>.*)/
  # TODO: Currently not activly used but these are the patterns we are looking for
  TV_SHOW_MATCHER_FULL = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/
  TV_SHOW_WITHOUT_EP_NAME = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*).*mkv/
  TV_SHOW_WITHOUT_DATE = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<episode_name>.*).*mkv/
  TV_SHOW_WITHOUT_NUMBER = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/
  TV_SHOW_WITHOUT_YEAR = /(?<title>.*)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/
  belongs_to :video, polymorphic: true, optional: true

  has_many :progresses, dependent: :destroy, as: :progressable

  scope :optimized, -> { where(optimized: true) }
  scope :checksum, -> { where.not(checksum: nil) }
  scope :missing_checksum, -> { where(checksum: nil) }

  def parsed_filename
    return @parsed_filename if @parsed_filename

    match = filename.match(MOVIE_MATCHER_WITH_YEAR) || filename.match(MOVIE_MATCHER)
    return @parsed_filename = Movie.new(nil, nil) if match.nil?

    @parsed_filename = Movie.new(match.named_captures['title'], match.named_captures['year'])
  end

  def parsed_dirname
    return @parsed_dirname if @parsed_dirname

    name = key.gsub("#{Config::Plex.newest.movie_path}/", '').split('/').first.to_s
    match = name.match(MOVIE_MATCHER_WITH_YEAR) || name.match(MOVIE_MATCHER)
    return @parsed_dirname = Movie.new(nil, nil) if match.nil?

    @parsed_dirname = Movie.new(match.named_captures['title'], match.named_captures['year'])
  end
end
