# frozen_string_literal: true

class CreateMkvService
  class Error < StandardError; end
  extend Dry::Initializer
  include MkvParser

  Result = Struct.new(:mkv_path, :success?)
  TMP_DIR = Rails.root.join('tmp/videos')
  param :test, Types::Bool, default: -> { false }
  option :disk_title, Types.Instance(DiskTitle)
  option :progress_listener, Types.Interface(:call)
  def self.call(...)
    new(...).call
  end

  def call
    Result.new(tmp_path, create_mkv.success?).tap do |result|
      rename_file if result.success?
    end
  end

  private

  def create_mkv # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @create_mkv ||= Open3.popen2e(cmd) do |stdin, std_out_err, wait_thr|
      stdin.close
      while raw_line = std_out_err.gets # rubocop:disable Lint/AssignmentInCondition
        begin
          progress_listener.call(parse_mkv_string(raw_line).first)
        rescue StandardError => e
          Rails.logger.error { "Error parsing mkv string: #{e.message}" }
          Rails.logger.error { e.backtrace.join("\n") }
        end
      end
      wait_thr.value
    end
  end

  def rename_file
    File.rename(tmp_dir.join(disk_title.name), tmp_path)
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
    @tmp_dir ||= tmp_path.dirname.tap(&method(:recreate_dir))
  end

  def tmp_path
    @tmp_path ||= disk_title.video.tmp_plex_path
  end

  def recreate_dir(dir)
    FileUtils.mkdir_p(dir)
  end

  def config
    @config ||= Config::MakeMkv.newest
  end
end
