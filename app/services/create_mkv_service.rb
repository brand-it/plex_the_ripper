# frozen_string_literal: true

class CreateMkvService
  class Error < StandardError; end

  extend Dry::Initializer

  Status = Struct.new(:dir, :mkv_path, :success)
  TMP_DIR = Rails.root.join('tmp', 'videos')

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: proc { Config::MakeMkv.newest.first }
  option :disk_title, Types.Instance(DiskTitle)
  option :video

  def call
    Status.new(dir, '', create.success?).tap do |status|
      if status.success
        status.mkv_path = Dir[file_path.join('*.mkv')].first
      else
        FileUtils.remove_entry_secure(file_path)
      end
    end
  end

  private

  def create
    Open3.popen2e({}, cmd) do |stdin, std_out_err, wait_thr|
      stdin.close
      ProcessOutput.new(std_out_err, video).gets
      wait_thr.value
    end
  end

  def cmd
    [
      config_make_mkv.settings.makemkvcon_path,
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
    @tmp_dir ||= TMP_DIR.join(video.model_name.singular, video.id.to_s).tap do |tmp_dir|
      FileUtils.remove_entry_secure(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)
    end
  end
end
