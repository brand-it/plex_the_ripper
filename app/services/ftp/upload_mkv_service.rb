# frozen_string_literal: true

module Ftp
  class UploadMkvService < Base
    extend Dry::Initializer
    include Wisper::Publisher

    option :video_blob, Types.Instance(::VideoBlob)

    def call
      broadcast(:upload_ready)
      ftp_destroy_if_file_exists
      ftp_create_directory
      try_to { ftp_upload_file }
      tmp_destroy_folder
      mark_as_uploaded!
      broadcast(:upload_finished, tracker:)
    rescue StandardError => e
      broadcast(:upload_error, e)
      raise e
    end

    private

    attr_reader :tracker

    def ftp_destroy_if_file_exists
      ftp.delete(video_blob.plex_path)
    rescue Net::FTPPermError => e
      Rails.logger.debug { "Net::FTPPermError #{__method__} #{e.message}" }
    end

    def ftp_create_directory
      current_dir = ''
      video_blob.plex_path.dirname.to_s.split('/').each do |directory|
        next current_dir += '' if directory.blank?

        current_dir += "/#{directory}"
        ftp.mkdir(current_dir)
      rescue Net::FTPPermError => e
        Rails.logger.debug { "Net::FTPPermError #{__method__} #{e.message}" }
      end
    end

    def ftp_upload_file
      @tracker = ProgressTracker::Base.new(
        total: bytes_to_kilobyte(file.size),
        rate_scale: ->(rate) { rate / 1024 }
      )
      broadcast(:upload_started, tracker:)
      ftp.putbinaryfile(file, video_blob.plex_path) do |chunk|
        increment_progress_bar(chunk.size)
        broadcast(:upload_progress, tracker:)
      end
    end

    def increment_progress_bar(increment)
      return if tracker.finished?

      @total_bytes ||= 0
      @total_bytes += increment
      tracker.progress = bytes_to_kilobyte(@total_bytes)
    rescue ProgressBar::InvalidProgressError
      tracker&.finish
    end

    def bytes_to_kilobyte(bites)
      bites / 1000
    end

    def mark_as_uploaded!
      video_blob.update!(uploaded_on: Time.current, uploadable: false)
    end

    def tmp_destroy_folder
      FileUtils.rm_rf(video_blob.tmp_plex_path)
    end

    def file
      @file ||= File.new(video_blob.tmp_plex_path)
    rescue Errno::ENOENT => e
      video_blob.destroy
      raise e
    end
  end
end
