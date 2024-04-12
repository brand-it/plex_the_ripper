# frozen_string_literal: true

class VideoBlobChecksumService
  extend Dry::Initializer
  TEMP_DIRECTORY = Rails.root.join('tmp/ftp/checksum').to_s

  option :video_blob, Types.Instance(VideoBlob)
  option :download_progress_listener, Types.Interface(:call), optional: true
  option :checksum_progress_listener, Types.Interface(:call), optional: true
  option :max_download_retries, default: -> { 5 }

  def self.call(...)
    new(...).call
  end

  def call
    create_tmp_directory
    return unless download.success?

    checksum = ChecksumService.call io: File.new(download.destination_path),
                                    progress_listener: checksum_progress_listener
    video_blob.update! checksum:
  ensure
    FileUtils.rm_rf(TEMP_DIRECTORY)
  end

  private

  def download
    return @download if defined?(@download)

    @download = Ftp::Download.call(
      video_blob:,
      destination_directory: TEMP_DIRECTORY,
      download_progress_listener:,
      max_retries: max_download_retries
    )
  end

  def create_tmp_directory
    return if Dir.exist? TEMP_DIRECTORY

    FileUtils.mkdir_p(TEMP_DIRECTORY)
  end
end
