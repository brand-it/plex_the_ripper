# frozen_string_literal: true

class CreateMkvService
  class Error < StandardError; end
  class ProcessOutput
    include MkvParser
    extend Dry::Initializer

    param :std_out_err
    param :video

    def gets
      while line = std_out_err.gets
        update_progress(line)
      end
    end

    def update_progress(line)
      parse_mkv_string(line).each do |progress|
        Rails.logger.debug(progress)
        case progress
        when MkvParser::PRGV
          mkv_progress.update!(percentage: progress.current.to_f)
        when MkvParser::PRGC, MkvParser::PRGT
          mkv_progress&.complete!
          mkv_progress(progress)
        end
      end
    end

    def mkv_progress(progress = nil)
      return @mkv_progress if progress.nil?

      @mkv_progress = MkvProgress.find_or_initialize_by(name: progress.name, video: video)
    end
  end
  Mkv = Struct.new(:file_path, :response)
  extend Dry::Initializer

  TMP_DIRECTORY = Rails.root.join('tmp', 'videos')

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: proc { Config::MakeMkv.newest.first }

  option :disk_name, Types::String
  option :title, Types::Integer
  option :video

  def call
    # Rails.logger.debug(mkv)
    # Mkv.new(, create
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
      "dev:#{disk_name}",
      title,
      file_path,
      '--progress=-same',
      '--robot',
      '--profile="FLAC"'
    ].join(' ')
  end

  def file_path
    TMP_DIRECTORY.join(video.model_name.singular, video.id.to_s)
  end
end
