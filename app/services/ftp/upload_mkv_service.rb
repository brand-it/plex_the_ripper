# frozen_string_literal: true

module Ftp
  class UploadMkvService < Base
    extend Dry::Initializer

    option :disk_title, Types.Instance(DiskTitle)
    option :progress_listener, Types.Interface(:call)
    attr_writer :total_completed_bytes

    def call
      ftp_destroy_if_file_exists
      ftp_create_directory
      ftp_upload_file
      tmp_destroy_folder
    end

    private

    def ftp_destroy_if_file_exists
      ftp.delete(disk_title.video.plex_path)
    rescue Net::FTPPermError => e
      Rails.logger.debug("Net::FTPPermError #{__method__} #{e.message}")
    end

    def ftp_create_directory
      ftp.mkdir(disk_title.video.plex_path.dirname)
    rescue Net::FTPPermError => e
      Rails.logger.debug("Net::FTPPermError #{__method__} #{e.message}")
    end

    def ftp_upload_file
      ftp.putbinaryfile(file, disk_title.video.plex_path) do |chunk|
        self.total_completed_bytes += chunk.size
        percentage = total_completed_bytes / file.size.to_f * 100
        progress_listener.call(percentage)
      end
    end

    def tmp_destroy_folder
      FileUtils.rm_rf(disk_title.video.tmp_plex_path.dirname)
    end

    def total_completed_bytes
      @total_completed_bytes ||= 0
    end

    def file
      @file ||= File.new(disk_title.video.tmp_plex_path)
    end
  end
end
