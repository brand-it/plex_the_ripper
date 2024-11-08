# frozen_string_literal: true

# Converts a key which in is a file path or name into something
# into the patterns that plex follows. Making a file path into
# something more then just a string value
class KeyParserService < ApplicationService
  EXTRA = VideoBlob::EXTRA_TYPES.map { _2[:dir_name] }.freeze
  PLEX_VERSIONS = 'Plex Versions'
  OPTIMIZED = 'Optimized for'
  BlobData = Data.define(
    :content_type,
    :edition,
    :episode,
    :extra_number,
    :extra_type,
    :extra,
    :filename,
    :optimized,
    :part,
    :plex_version,
    :season,
    :title,
    :type,
    :year,
    :episode_last
  ) do
    def initialize(
      filename:,
      title:,
      type:,
      year:,
      content_type:,
      edition: nil,
      episode_last: nil,
      episode: nil,
      extra_number: nil,
      extra: nil,
      optimized: false,
      part: nil,
      plex_version: false,
      season: nil
    )
      extra_type = VideoBlob::EXTRA_TYPES.find { extra&.include?(_1[1][:dir_name]) }&.first&.to_sym
      extra_type ||= :feature_films
      super(
        edition: edition.presence&.strip&.force_encoding(Encoding::UTF_8),
        episode: episode.presence&.to_i,
        extra_number: extra_number.presence&.to_i,
        extra: extra.presence&.strip&.force_encoding(Encoding::UTF_8),
        filename: filename.presence&.strip&.force_encoding(Encoding::UTF_8),
        plex_version: Types::Coercible::Bool[plex_version],
        season: season&.to_i,
        title: title.presence&.strip&.gsub(/ {2,}/, ' ')&.gsub(/ (-\w)/, '\\1')&.force_encoding(Encoding::UTF_8),
        type: type.to_s,
        year: year.presence&.to_i,
        content_type: content_type.presence&.strip,
        optimized: Types::Coercible::Bool[optimized],
        extra_type:,
        part:,
        episode_last:
      )
    end

    def movie?
      type == 'Movie'
    end

    def tv?
      type == 'Tv'
    end
  end

  # Helper Regex
  SPACE_OR_NOTHING = /(?:\s+|)/

  VIDEO_FORMATS = [
    '.avi', '.mp4', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.mpeg',
    '.mpg', '.3gp', '.m4v', '.swf', '.rm', '.vob',
    '.ogv', '.ts', '.f4v', '.divx', '.asf', '.mts', '.m2ts', '.dv',
    '.mxf', '.f4p', '.gxf', '.m2v', '.yuv', '.amv',
    '.svi', '.nsv'
  ].freeze
  VIDEO_MIME_TYPES = {
    'avi' => 'video/x-msvideo',
    'mp4' => 'video/mp4',
    'mkv' => 'video/x-matroska',
    'mov' => 'video/quicktime',
    'wmv' => 'video/x-ms-wmv',
    'flv' => 'video/x-flv',
    'webm' => 'video/webm',
    'mpeg' => 'video/mpeg',
    'mpg' => 'video/mpeg',
    '3gp' => 'video/3gpp',
    'm4v' => 'video/x-m4v',
    'swf' => 'application/x-shockwave-flash',
    'rm' => 'application/vnd.rn-realmedia',
    'vob' => 'video/dvd',
    'ogv' => 'video/ogg',
    'ts' => 'video/mp2t',
    'f4v' => 'video/mp4',
    'divx' => 'video/divx',
    'asf' => 'video/x-ms-asf',
    'mts' => 'model/vnd.mts',
    'm2ts' => 'video/mp2t',
    'dv' => 'video/x-dv',
    'mxf' => 'application/mxf',
    'f4p' => 'video/mp4',
    'gxf' => 'application/gxf',
    'm2v' => 'video/mpeg',
    'yuv' => 'application/octet-stream',
    'amv' => 'video/x-amv',
    'svi' => 'video/vnd.sealedmedia.softseal.mov',
    'nsv' => 'video/x-nsv'
  }.freeze
  TITLE_MATCHER = /(?<title>.*)/
  EDITION = /{edition-(?<edition>.*)}/
  MATCHER_WITH_YEAR_EDITION = /#{TITLE_MATCHER}[(](?<year>\d{4})[)]#{SPACE_OR_NOTHING}#{EDITION}/
  MATCHER_WITH_YEAR = /#{TITLE_MATCHER}[(](?<year>\d{4})[)]/

  # TODO: Currently not activly used but these are the patterns we are looking for
  TV_SHOW_SEASON_EPISODE = /[sS](?<season>\d+)[eE](?<episode>\d+)/
  TV_SHOW_SEASON_EPISODE_LAST = /[sS](?<season>\d+)[eE](?<episode>\d+)-[eE](?<episode_last>\d+)/
  TV_SHOW_MATCHER_FULL = /#{MATCHER_WITH_YEAR}.*-#{SPACE_OR_NOTHING}#{TV_SHOW_SEASON_EPISODE}#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<date>.*)#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_EP_NAME = /#{MATCHER_WITH_YEAR}.*-#{SPACE_OR_NOTHING}#{TV_SHOW_SEASON_EPISODE}#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<date>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_DATE = /#{MATCHER_WITH_YEAR}.*-#{SPACE_OR_NOTHING}#{TV_SHOW_SEASON_EPISODE}#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_NUMBER = /#{MATCHER_WITH_YEAR}.*-#{SPACE_OR_NOTHING}(?<date>.*)#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_WITHOUT_YEAR = /#{TITLE_MATCHER}.*-#{SPACE_OR_NOTHING}#{TV_SHOW_SEASON_EPISODE}#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<date>.*)#{SPACE_OR_NOTHING}-#{SPACE_OR_NOTHING}(?<episode_name>.*).*#{Regexp.union(VIDEO_FORMATS)}/
  TV_SHOW_NUMBER_ONLY = /#{TV_SHOW_SEASON_EPISODE}\.*#{Regexp.union(VIDEO_FORMATS)}/

  param :key, Types::Coercible::StrippedString.constructor { _1.force_encoding(Encoding::UTF_8) }
  option :movie_path, Types::Coercible::StrippedString.optional, default: -> { Config::Plex.newest&.movie_path }
  option :tv_path, Types::Coercible::StrippedString.optional, default: -> { Config::Plex.newest&.tv_path }

  def call
    return unless video_file?

    if key_movie?
      parsed_movie
    elsif key_tv_show?
      parsed_tv_show
    end
  end

  private

  def video_file?
    VIDEO_FORMATS.any? { key.ends_with?(_1) }
  end

  def key_movie?
    return false if movie_path.blank?

    key&.starts_with?(movie_path) || false
  end

  def key_tv_show?
    return false if tv_path.blank?

    key&.starts_with?(tv_path) || false
  end

  def parsed_tv_show
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

    BlobData.new(
      content_type:,
      episode: match['episode'],
      filename:,
      optimized:,
      plex_version:,
      season: match['season'],
      title: dir_match['title'].presence || match['title'],
      type: 'Tv',
      year: dir_match['year'].presence || match['year'],
      part:,
      episode_last:
    )
  end

  def parsed_movie
    match = (
        filename.match(MATCHER_WITH_YEAR_EDITION) ||
        filename.match(MATCHER_WITH_YEAR) ||
        filename.match(TITLE_MATCHER)
      )&.named_captures || {}

    dir_match = (
      directory_name.match(MATCHER_WITH_YEAR_EDITION) ||
      directory_name.match(MATCHER_WITH_YEAR) ||
      directory_name.match(TITLE_MATCHER)
    )&.named_captures || {}

    BlobData.new(
      content_type:,
      edition: dir_match['edition'].presence || match['edition'],
      extra_number:,
      extra:,
      filename:,
      optimized:,
      plex_version:,
      title: dir_match['title'].presence || match['title'],
      type: 'Movie',
      year: dir_match['year'].presence || match['year']
    )
  end

  def simplified_key
    return unless key_movie? || key_tv_show?

    @simplified_key ||= key.gsub(key_movie? ? movie_path : tv_path, '').split('/').compact_blank.join('/')
  end

  def directory_name
    return @directory_name if defined?(@directory_name)
    return '' if key.blank? || (!key_movie? && !key_tv_show?)

    paths = simplified_key.split('/')
    return '' if paths.size <= 1

    @directory_name = simplified_key.split('/').first.to_s.strip
  end

  def filename
    @filename ||= key.split('/').last.to_s.strip
  end

  def extra
    (simplified_key.gsub("#{directory_name}/", '').split('/') & EXTRA).first
  end

  def extra_number
    (filename.match(/#(\d+)/) || [])[1]
  end

  def plex_version
    simplified_key.gsub("#{directory_name}/", '').include?(PLEX_VERSIONS)
  end

  def content_type
    VIDEO_MIME_TYPES[filename.split('.').last]
  end

  def optimized
    plex_version && simplified_key.gsub("#{directory_name}/", '').include?(OPTIMIZED)
  end

  def part
    (filename.match(/\spart(\d+)/) || filename.match(/\spt(\d+)/) || [])[1]&.to_i
  end

  def episode_last
    (filename.match(TV_SHOW_SEASON_EPISODE_LAST)&.named_captures || {})['episode_last']&.to_i
  end
end
