# frozen_string_literal: true

module Ftp
  class UploadMkvService < Base
    extend Dry::Initializer

    option :disk_title, Types.Instance(DiskTitle)
    option :progress_listener, Types.Interface(:call), optional: true

    def call
      ftp_destroy_if_file_exists
      ftp_create_directory
      try_to { ftp_upload_file }
      tmp_destroy_folder
    end

    private

    def ftp_destroy_if_file_exists
      ftp.delete(disk_title.video.plex_path)
    rescue Net::FTPPermError => e
      Rails.logger.debug { "Net::FTPPermError #{__method__} #{e.message}" }
    end

    def ftp_create_directory
      current_dir = ''
      disk_title.video.plex_path.dirname.to_s.split('/').each do |directory|
        next current_dir += '' if directory.blank?

        current_dir += "/#{directory}"
        ftp.mkdir(current_dir)
      rescue Net::FTPPermError => e
        Rails.logger.debug { "Net::FTPPermError #{__method__} #{e.message}" }
      end
    end

    def ftp_upload_file
      ftp.putbinaryfile(file, disk_title.video.plex_path) do |chunk|
        progress_listener&.call(chunk_size: chunk.size)
      end
    end

    def tmp_destroy_folder
      FileUtils.rm_rf(disk_title.video.tmp_plex_path)
    end

    def file
      @file ||= File.new(disk_title.video.tmp_plex_path)
    end
  end
end
