# frozen_string_literal: true

class VideoBlobChecksumService
  extend Dry::Initializer
  TEMP_DIRECTORY = Rails.root.join('tmp/ftp/checksum').to_s

  option :video_blob, Types.Instance(VideoBlob)
  option :progress_listener, Types.Interface(:call), optional: true
  option :download_finished_listener, Types.Interface(:call), optional: true
  option :max_download_retries, default: -> { 5 }

  def self.call(*args)
    new(*args).call
  end

  def call
    create_tmp_directory
    download_finished_listener&.call(result: download)
    return unless download.success?

    video_blob.update!(
      checksum: ChecksumService.call(io: File.new(download.destination_path))
    )
  ensure
    FileUtils.rm_rf(TEMP_DIRECTORY)
  end

  private

  def download
    return @download if defined?(@download)

    @download = Ftp::Download.call(
      video_blob: video_blob,
      destination_directory: TEMP_DIRECTORY,
      progress_listener: progress_listener,
      max_retries: max_download_retries
    )
  end

  def create_tmp_directory
    return if Dir.exist? TEMP_DIRECTORY

    FileUtils.mkdir_p(TEMP_DIRECTORY)
  end
end
