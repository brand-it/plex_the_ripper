# frozen_string_literal: true

module Ftp
  class Download < Base
    extend Dry::Initializer
    option :video_blob, Types.Instance(VideoBlob)
    option :directory, Types::String
    option :progress_listener, Types.Interface(:call)

    def call
      raise "could not find #{directory}" unless Dir.exist? directory
      return Result.new(progress, download_valid?) if progress.completed?

      download

      Result.new(progress, download_valid?)
    end

    private

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
        progress_listener.call(video_blob, chunk.size)
      rescue StandardError => e
        Rails.logger.error e.message
      end
    end

    def destination_path
      @destination_path ||= "#{directory}/#{video_blob.filename}"
    end

    def download_valid?
      File.size?(destination_path) == video_blob.byte_size
    end

    Result = Struct.new(:progress, :success?)
  end
end