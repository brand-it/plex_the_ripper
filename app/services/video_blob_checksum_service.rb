# frozen_string_literal: true

class VideoBlobChecksumService
  extend Dry::Initializer
  TEMP_DIRECTORY = Rails.root.join('tmp/ftp/checksum').to_s

  option :video_blob, Types.Instance(VideoBlob)
  option :progress_listener, Types.Interface(:call), optional: true

  def call
    FileUtils.mkdir_p(TEMP_DIRECTORY) unless Dir.exist? TEMP_DIRECTORY
    result = Ftp::Download.new(
      video_blob: video_blob,
      directory: TEMP_DIRECTORY,
      progress_listener: progress_listener
    ).call
    raise 'failed to download file' unless result.success?

    video_blob.update!(checksum: ChecksumService.call(io: File.new(result.destination_path)))
  ensure
    FileUtils.rm_rf(TEMP_DIRECTORY)
  end
end
