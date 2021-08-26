# frozen_string_literal: true

module Ftp
  class Download < Base
    extend Dry::Initializer
    option :video_blob, Types.Instance(VideoBlob)
    option :destination_directory, Types::String
    option :progress_listener, Types.Interface(:call), optional: true
    option :max_retries, Types::Integer, default: -> { 5 }

    def call
      validate_destination_directory!
      return Result.new(progress, download_valid?, destination_path) if progress.completed?

      progress_listener&.call(chunk_size: destination_file_size)
      try_to { download }

      Result.new(progress, download_valid?, destination_path)
    end

    private

    def validate_destination_directory!
      return if Dir.exist? destination_directory

      raise "could not find #{destination_directory}"
    end

    def progress
      @progress ||= Progress.find_or_create_by(
        key: Progress.generate_key([video_blob.key, destination_path]),
        descriptive: :download_ftp,
        progressable: video_blob
      )
    end

    def download
      ftp.resume = true
      ftp.getbinaryfile(video_blob.key, destination_path) do |chunk|
        progress_listener&.call(chunk_size: chunk.size)
      end
    end

    def destination_path
      @destination_path ||= "#{destination_directory}/#{video_blob.filename}"
    end

    def download_valid?
      destination_file_size == video_blob.byte_size && validate_checksum?
    end

    def destination_file_size
      File.size?(destination_path) || 0
    end

    def validate_checksum?
      video_blob.checksum.blank? ||
        video_blob.checksum == ChecksumService.call(io: File.new(destination_path))
    end

    Result = Struct.new(:progress, :success?, :destination_path)
  end
end
