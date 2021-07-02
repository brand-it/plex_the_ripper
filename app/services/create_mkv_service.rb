# frozen_string_literal: true

class CreateMkvService
  class Error < StandardError; end
  extend Dry::Initializer
  include MkvParser

  Result = Struct.new(:dir, :mkv_path, :success?)
  TMP_DIR = Rails.root.join('tmp/videos')

  option :disk_title, Types.Instance(DiskTitle)
  option :progress_listener, Types.Interface(:call)

  def call
    Result.new tmp_dir, tmp_dir.join(disk_title.name), create_mkv.success?
  end

  private

  def create_mkv
    @create_mkv ||= Open3.popen2e({}, cmd) do |stdin, std_out_err, wait_thr|
      stdin.close
      Thread.new do
        while raw_line = std_out_err.gets # rubocop:disable Lint/AssignmentInCondition
          progress_listener.call(parse_mkv_string(raw_line).first)
        end
      end.join
      wait_thr.value
    end
  end

  def cmd
    [
      config.settings.makemkvcon_path,
      'mkv',
      "dev:#{disk_title.disk.disk_name}",
      disk_title.title_id,
      tmp_dir,
      '--progress=-same',
      '--robot',
      '--profile="FLAC"'
    ].join(' ')
  end

  def tmp_dir
    @tmp_dir ||= TMP_DIR.join(disk_title.id.to_s).tap do |tmp_dir|
      recreate_dir(tmp_dir)
    end
  end

  def recreate_dir(dir)
    FileUtils.remove_entry_secure(dir) if File.exist?(dir)
    FileUtils.mkdir_p(dir)
  end

  def config
    @config ||= Config::MakeMkv.newest.first
  end
end
