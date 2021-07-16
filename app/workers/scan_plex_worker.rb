# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  MOVIE_MATCHER_WITH_YEAR = /(?<title>.*)\s\((?<year>.*)\).*mkv/.freeze
  MOVIE_MATCHER = /(?<title>.*).*mkv/.freeze
  TV_SHOW_MATCHER_FULL = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_EP_NAME = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<date>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_DATE = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<number>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_NUMBER = /(?<title>.*)\s\((?<year>.*)\)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze
  TV_SHOW_WITHOUT_YEAR = /(?<title>.*)\s-\s(?<number>.*)\s-\s(?<date>.*)\s-\s(?<episode_name>.*).*mkv/.freeze

  def call
    result = Ftp::VideoScannerService.call
    result.movies.each do |movie|
      matcher = movie_matcher(movie)
      next unless matcher

      video = search_for_video(matcher)
      next unless video

      Rails.logger.info(
        "#{video.new_record? ? 'Creating' : 'Updating'}"\
        " #{video.title} (#{video.release_or_air_date&.year})"
      )
      video.save!
    end
  end

  private

  def search_for_video(matcher)
    VideoSearchQuery.new(query: matcher['title']).results.find do |v|
      matcher.names.include?('year').blank? || v.release_or_air_date&.year == matcher['year']
    end
  end

  def movie_matcher(movie)
    movie[:file_name].match(MOVIE_MATCHER_WITH_YEAR) || movie[:file_name].match(MOVIE_MATCHER)
  end
end
