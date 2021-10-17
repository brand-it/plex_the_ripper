# frozen_string_literal: true

module Ftp
  class Download < Base
    extend Dry::Initializer
    option :video_blob, Types.Instance(VideoBlob)
    option :destination_directory, Types::String
    option :download_progress_listener, Types.Interface(:call), optional: true
    option :checksum_progress_listener, Types.Interface(:call), optional: true

    def call
      validate_destination_directory!

      download_progress_listener&.call(chunk_size: destination_file_size)
      try_to { download }

      Result.new(failure_message, download_valid?, destination_path).tap { ftp.close }
    end

    private

    def validate_destination_directory!
      return if Dir.exist? destination_directory

      raise "could not find #{destination_directory}"
    end

    def download
      ftp.resume = true
      ftp.getbinaryfile(video_blob.key, destination_path) do |chunk|
        download_progress_listener&.call(chunk_size: chunk.size)
      end
    end

    def destination_path
      @destination_path ||= "#{destination_directory}/#{video_blob.filename}"
    end

    def download_valid?
      valid_byte_size? && valid_checksum?
    end

    def valid_byte_size?
      destination_file_size == video_blob.byte_size
    end

    def destination_file_size
      File.size?(destination_path) || 0
    end

    def valid_checksum?
      video_blob.checksum.blank? || video_blob.checksum == download_checksum
    end

    def download_checksum
      @download_checksum ||= ChecksumService.call io: File.new(destination_path),
                                                  progress_listener: checksum_progress_listener
    end

    def failure_message
      if !valid_checksum?
        "expected checksum to be #{video_blob.checksum} but was #{download_checksum}"
      elsif !valid_byte_size?
        "expected byte size to be #{video_blob.byte_size} but was #{destination_file_size}"
      end
    end

    Result = Struct.new(:failure_message, :success?, :destination_path)
  end
end
