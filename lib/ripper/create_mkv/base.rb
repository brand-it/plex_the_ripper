# frozen_string_literal: true

class CreateMKV
  class Base
    include TimeHelper
    include HumanizerHelper
    include Progressable

    attr_accessor(
      :run_time, :directory, :started_at, :completed_at, :status, :notification_percentages,
      :backup, :progressbar
    )
    def initialize
      self.started_at = nil
      self.completed_at = nil
      self.status = 'ready'
      self.directory = AskForFilePathBuilder.path
      self.notification_percentages = NOTIFICATION_PERCENTAGES.dup
      self.progressbar = Ripper::ProgressBar.create
      self.backup = CreateMKV::MakeBackup.new
      create_directory_path
    end

    def create_backup!
      return if Config.configuration.mkv_from_file.to_s != ''
      return

      backup.start!
    end

    def create_mkv
      Config.configuration.selected_titles.each_with_index do |title, index|
        Logger.info("Ripping Title #{title}")
        response = mkv_system!(title: title)
        process_status!(response, title)
        # We want to rename the mkv file for each success. That was if there is a failure of
        # one of them it will still get he correct name for the rest of them.
        if success?
          rename_mkv(mkv_file_name: File.basename(mkv_files(reload: true).last), index: index)
        end
      end
    end

    # Define this method on each child class. If not defined that is ok.   We will just assume you wanted
    # that and just display a warning to the user.
    def rename_mkv(mkv_file_name:, index:)
      Logger.warning("rename_mkv is not defined for #{self.class.name}")
    end

    def mkv_files(reload: false)
      @mkv_files = nil if reload
      @mkv_files ||= Dir.entries(directory).select do |video|
        File.extname(video) == '.mkv'
      end.sort
    end

    def notify_success
      Notification.send(
        "Finished ripping #{humanize_disk_info}",
        "It took a total of #{human_seconds(run_time)} to rip #{Config.configuration.video_name}",
        message_color: 'green'
      )
    end

    def notify_slack_failure
      Notification.send(
        "Failed ripping #{humanize_disk_info}",
        "There was a issue making a copy of #{Config.configuration.video_name}",
        message_color: 'red'
      )
    end

    def success?
      status == 'success'
    end

    def failed?
      status == 'failed'
    end

    def ready?
      status == 'ready'
    end

    def started?
      status == 'started'
    end

    def success!
      backup.destroy!
      notify_slack_success
      self.status = 'success'
    end

    def failure!
      backup.destroy! unless backup.success
      self.completed_at = Time.now
      self.status = 'failed'
      notify_slack_failure
    end

    def start!
      self.started_at = Time.now
      self.status = 'started'
    end

    def run_time
      return 0 if started_at.nil? || completed_at.nil?

      completed_at - started_at
    end

    def mkv(title: 'all')
      source = backup.exists? ? backup.source : Config.configuration.disk_source
      [
        Shellwords.escape(Config.configuration.makemkvcon_path),
        'mkv',
        source,
        title,
        Shellwords.escape(directory),
        '--progress=-same',
        '--noscan',
        '--robot',
        '--profile="FLAC"'
      ].join(' ')
    end

    def mkv_system!(title:)
      semaphore = Mutex.new
      Logger.debug(mkv(title: title))
      Thread.report_on_exception = true
      Open3.popen2e({}, mkv(title: title)) do |stdin, std_out_err, wait_thr|
        stdin.close
        Thread.new do
          while raw_line = std_out_err.gets
            semaphore.synchronize { process_progress_from(raw_line) }
          end
        end.join
        wait_thr.value
      end
    end

    def create_directory_path
      return if directory.nil?
      return if File.exist?(directory)

      Logger.info("Creating file path #{directory}")
      FileUtils.mkdir_p(directory)
    end

    def process_status!(response, title)
      if response.success? && Dir[directory + '/*'].any?
        success!
      else
        Logger.error("Could not rip file #{Config.configuration.video_name}, #{mkv(title: title)}")
        failure!
      end
    end
  end
end
