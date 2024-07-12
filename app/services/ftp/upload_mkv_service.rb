# frozen_string_literal: true

module Ftp
  class UploadMkvService < Base
    extend Dry::Initializer
    include Wisper::Publisher

    option :disk_title, Types.Instance(DiskTitle)

    def call
      broadcast(:started)
      ftp_destroy_if_file_exists
      ftp_create_directory
      try_to { ftp_upload_file }
      tmp_destroy_folder
      broadcast(:finished)
    end

    private

    def ftp_destroy_if_file_exists
      ftp.delete(disk_title.plex_path)
    rescue Net::FTPPermError => e
      Rails.logger.debug { "Net::FTPPermError #{__method__} #{e.message}" }
    end

    def ftp_create_directory
      current_dir = ''
      disk_title.plex_path.dirname.to_s.split('/').each do |directory|
        next current_dir += '' if directory.blank?

        current_dir += "/#{directory}"
        ftp.mkdir(current_dir)
      rescue Net::FTPPermError => e
        Rails.logger.debug { "Net::FTPPermError #{__method__} #{e.message}" }
      end
    end

    def ftp_upload_file
      ftp.putbinaryfile(file, disk_title.plex_path) do |chunk|
        broadcast(:update_progress, chunk_size: chunk.size)
      end
    end

    def tmp_destroy_folder
      FileUtils.rm_rf(disk_title.tmp_plex_path)
    end

    def file
      @file ||= File.new(disk_title.tmp_plex_path)
    end
  end
end
