# frozen_string_literal: true

class CreateMkvService
  class Error < StandardError; end
  extend Dry::Initializer
  include MkvParser

  Result = Struct.new(:mkv_path, :success?)
  TMP_DIR = Rails.root.join('tmp/videos')

  option :disk_title, Types.Instance(DiskTitle)
  option :progress_listener, Types.Interface(:call)

  def call
    Result.new(tmp_path, create_mkv.success?).tap do |result|
      rename_file if result.success?
    end
  end

  private

  def create_mkv
    @create_mkv ||= Open3.popen2e(cmd) do |stdin, std_out_err, wait_thr|
      stdin.close
      while raw_line = std_out_err.gets # rubocop:disable Lint/AssignmentInCondition
        progress_listener.call(parse_mkv_string(raw_line).first)
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
    FileUtils.remove_entry_secure(dir) if File.exist?(dir)
    FileUtils.mkdir_p(dir)
  end

  def config
    @config ||= Config::MakeMkv.newest
  end
end
