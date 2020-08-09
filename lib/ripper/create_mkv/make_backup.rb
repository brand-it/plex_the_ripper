# frozen_string_literal: true

class CreateMKV
  class MakeBackup
    include Progressable

    attr_accessor :directory, :backup_file, :progressbar, :success

    def initialize
      self.directory = "#{AskForFilePathBuilder.path}/backup"
      self.progressbar = Ripper::ProgressBar.create
      self.success = false
    end

    def start!
      if exists?
        Logger.info("Backup is already present nice we can skip that step #{directory}")
        return
      end
      backup
    end

    def destroy!
      Logger.warning("Destroying backup #{directory}")
      FileUtils.rm_rf(directory)
    end

    def exists?
      File.directory?(directory)
    end

    def source
      "file:#{Shellwords.escape(directory)}/BDMV"
    end

    private

    def backup_command
      [
        Shellwords.escape(Config.configuration.makemkvcon_path),
        'backup',
        "disc:#{Config.configuration.selected_disc_info.dev}",
        Shellwords.escape(directory),
        '--decrypt',
        '--cache=16',
        '--noscan',
        '-r',
        '--progress=-same'
      ].join(' ')
    end

    def backup
      Thread.report_on_exception = true
      Logger.debug(backup_command)
      Open3.popen2e({}, backup_command) do |stdin, std_out_err, wait_thr|
        stdin.close
        Thread.new do
          while raw_line = std_out_err.gets
            process_progress_from(raw_line)
          end
        end.join
        wait_thr.value
      end
    end

    def process_status!(response)
      if response.success?
        self.success = true
        progress_done
      else
        destroy!
        self.success = false
      end
    end
  end
end
