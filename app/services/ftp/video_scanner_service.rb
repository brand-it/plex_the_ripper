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
      videos = ftp.mlsd(path).flat_map do |entry|
        next collect_mkv_files([path, entry.pathname].join('/')) if entry.type == 'dir'

        build_video(path, entry)
      end
      videos.compact.sort_by { |c| c[:file_name] }
    end

    def build_video(path, entry)
      return unless entry.pathname.end_with?('.mkv')

      Rails.logger.info("Found #{safe_encode([path, entry.pathname].join('/'))}")
      { path: safe_encode(path), file_name: safe_encode(entry.pathname) }
    end

    def safe_encode(string)
      string.force_encoding('ASCII-8BIT')
            .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end
  end
end
