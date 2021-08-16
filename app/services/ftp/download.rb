# frozen_string_literal: true

module Ftp
  class Download < Base
    extend Dry::Initializer
    option :video_blob, Types.Instance(VideoBlob)
    option :directory, Types::String
    option :progress_listener, Types.Interface(:call)

    def call
      raise "could not find #{directory}" unless Dir.exist? directory
      return if File.exist?("#{directory}/#{video_blob.filename}")

      ftp.getbinaryfile(video_blob.key, "#{directory}/#{video_blob.filename}") do |chunk|
        begin
          progress_listener.call(video_blob, chunk.size)
        rescue StandardError => e
          Rails.logger.error e.message
        end
      end
    end
  end
end
