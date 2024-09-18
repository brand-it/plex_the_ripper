# frozen_string_literal: true

module Ftp
  class VideoScannerService < Base
    Result = Struct.new(:movies, :tv_shows)

    def call
      collect_mkv_files(plex_config.settings_movie_path) +
        collect_mkv_files(plex_config.settings_tv_path)
    end

    def collect_mkv_files(path)
      ftp.mlsd(path).flat_map do |entry|
        next collect_mkv_files([path, entry.pathname].join('/')) if entry.type == 'dir'

        build_video(path, entry)
      end.compact.sort_by(&:filename)
    end

    def build_video(path, entry)
      service = KeyParserService.new([path, entry.pathname].join('/'))
      parsed = service.call
      return if parsed.nil?

      find_or_initialize_by(service.key).tap do |video_blob|
        video_blob.assign_attributes filename: parsed.filename,
                                     content_type: parsed.content_type,
                                     optimized: parsed.optimized,
                                     byte_size: entry.size,
                                     extra_type_number: parsed.extra_number,
                                     extra_type: parsed.extra_type
        video_blob.uploaded_on ||= Time.current
      end
    end

    def find_or_initialize_by(key)
      preloaded_video_blobs[key] || VideoBlob.new(key:)
    end

    def preloaded_video_blobs
      @preloaded_video_blobs ||= {}.tap do |hash|
        VideoBlob.includes(:video).find_each do |video_blob|
          hash[video_blob.key] ||= video_blob
        end
      end
    end
  end
end
