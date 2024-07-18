# frozen_string_literal: true

class CreateMkvService
  class Error < StandardError; end
  extend Dry::Initializer
  include Wisper::Publisher
  include MkvParser

  Result = Struct.new(:mkv_path, :success) do
    def success?
      success
    end
  end
  TMP_DIR = Rails.root.join('tmp/videos')

  option :disk_title, Types.Instance(DiskTitle)
  option :extra_type, Types::Coercible::String, default: -> { VideoBlob::EXTRA_TYPES.first }

  def self.call(...)
    new(...).call
  end

  def call
    disk_title.update!(video_blob:)
    broadcast(:start, video_blob)
    Result.new(video_blob.tmp_plex_path, create_mkv.success?).tap do |result|
      if result.success?
        rename_file
        video_blob.update!(byte_size:, uploadable: true)
        disk_title.update!(ripped_at: Time.current)
        broadcast(:success, video_blob)
      else
        broadcast(:failure, video_blob)
      end
    rescue StandardError => e
      broadcast(:failure, video_blob, e)
      result.success = false
    end
  end

  private

  def create_mkv
    @create_mkv ||= Open3.popen2e(cmd) do |stdin, std_out_err, wait_thr|
      stdin.close
      while raw_line = std_out_err.gets # rubocop:disable Lint/AssignmentInCondition
        begin
          broadcast(:raw_line, parse_mkv_string(raw_line).first, video_blob)
        rescue StandardError => e
          Rails.logger.error { "Error parsing mkv string: #{e.message}" }
          Rails.logger.error { e.backtrace.join("\n") }
        end
      end
      wait_thr.value
    end
  end

  def rename_file
    File.rename(tmp_dir.join(disk_title.name), video_blob.tmp_plex_path)
  end

  def byte_size
    File.size(tmp_dir.join(disk_title.name))
  end

  def cmd
    [
      Shellwords.escape(config.settings.makemkvcon_path),
      'mkv',
      Shellwords.escape("dev:#{disk_title.disk.disk_name}"),
      Shellwords.escape(disk_title.title_id),
      Shellwords.escape(tmp_dir),
      '--progress=-same',
      '--robot',
      '--profile="FLAC"'
    ].join(' ')
  end

  def tmp_dir
    @tmp_dir ||= video_blob.tmp_plex_dir.tap(&method(:recreate_dir))
  end

  def video_blob
    @video_blob ||= if extra_type == 'feature_films'
                      VideoBlob.find_or_create_by!(
                        video: disk_title.video,
                        episode: disk_title.episode,
                        extra_type:
                      )
                    else
                      VideoBlob.create!(
                        video: disk_title.video,
                        episode: disk_title.episode,
                        extra_type:
                      )
                    end
  end

  def recreate_dir(dir)
    FileUtils.mkdir_p(dir)
  end

  def config
    @config ||= Config::MakeMkv.newest
  end
end
