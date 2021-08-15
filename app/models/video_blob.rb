# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id           :integer          not null, primary key
#  byte_size    :bigint           not null
#  content_type :string           not null
#  filename     :string           not null
#  key          :string           not null
#  metadata     :text
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
  # rubocop:disable Layout/LineLength
  MOVIE_MATCHER_WITH_YEAR = /(?<title>.*)[(](?<year>\d{4})[)]/.freeze
  MOVIE_MATCHER = /(?<title>.*)[.]mkv/.freeze
  TV_SHOW_MATCHER_FULL = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_EP_NAME = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_DATE = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_NUMBER = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_YEAR = /(?<title>.*)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  # rubocop:enable Layout/LineLength

  belongs_to :video, polymorphic: true, optional: true

  def parsed_filename
    @parsed_filename ||= begin
      match = filename.match(MOVIE_MATCHER_WITH_YEAR) || filename.match(MOVIE_MATCHER)
      OpenStruct.new(match.names.to_h { |name| [name, match[name]] })
    end
  end
end
