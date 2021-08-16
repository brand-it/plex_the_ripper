# frozen_string_literal: true

module Ftp
  class VideoScannerService < Base
    Result = Struct.new(:movies, :tv_shows)
    def self.call
      new.call
    end

    def call
      Result.new(
        collect_mkv_files(plex_config.settings_movie_path),
        collect_mkv_files(plex_config.settings_tv_path)
      )
    end

    def collect_mkv_files(path)
      ftp.mlsd(path).flat_map do |entry|
        next collect_mkv_files([path, entry.pathname].join('/')) if entry.type == 'dir'

        build_video(path, entry)
      end.compact.sort_by(&:filename)
    end

    def build_video(path, entry)
      return unless entry.pathname.end_with?('.mkv') || entry.pathname.end_with?('.mp4')

      key = [path, entry.pathname].join('/')
      Rails.logger.debug { "Building #{key}" }
      VideoBlob.find_or_initialize_by(key: safe_encode(key), service_name: :ftp).tap do |video_blob|
        video_blob.update! filename: safe_encode(entry.pathname),
                           content_type: content_type(entry),
                           optimized: path.include?('Optimized for'),
                           byte_size: entry.size
      end
    end

    def content_type(entry)
      return 'video/x-matroska' if entry.pathname.end_with?('.mkv')
      return 'video/mp4' if entry.pathname.end_with?('.mp4')

      raise 'Unsupported file type'
    end

    def safe_encode(string)
      string.force_encoding(Encoding::UTF_8)
    end
  end
end
