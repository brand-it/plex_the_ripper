# frozen_string_literal: true

class CreateMKV
  class Base
    include TimeHelper
    include HumanizerHelper
    include Progressable

    attr_accessor(
      :run_time, :directory, :started_at, :completed_at, :status, :notification_percentages,
      :progressbar, :newest_mkv_file_path
    )
    def initialize
      self.started_at = nil
      self.completed_at = nil
      self.status = 'ready'
      self.directory = AskForFilePathBuilder.path
      self.notification_percentages = NOTIFICATION_PERCENTAGES.dup
      self.progressbar = Ripper::ProgressBar.create
      create_directory_path
    end

    def create_mkv
      Config.configuration.selected_titles.each_with_index do |title, index|
        Logger.info("Ripping Title #{title}")
        response = mkv_system!(title: title)
        process_status!(response, title)
        # We want to rename the mkv file for each success. That was if there is a failure of
        # one of them it will still get he correct name for the rest of them.
        rename_mkv(mkv_file_name: File.basename(newest_mkv_file_path), index: index) if success?
      end
      send_success_notification if success?
    end

    def rename_mkv(mkv_file_name:, index:)
      raise Plex::Ripper::Abort, "rename_mkv is not defined for #{self.class.name}"
    end

    def mkv_files
      Dir.entries(directory).select do |video|
        File.extname(video) == '.mkv'
      end.sort
    end

    def send_success_notification
      Notification.send(
        "Finished ripping #{humanize_disk_info}",
        "It took a total of #{human_seconds(run_time)} to rip #{Config.configuration.video_name}",
        message_color: 'green'
      )
    end

    def send_failure_notification
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
      self.completed_at = Time.now
      self.status = 'success'
    end

    def failure!
      self.completed_at = Time.now
      self.status = 'failed'
      self.newest_mkv_file_path = nil
      send_failure_notification
    end

    def start!
      self.started_at = Time.now
      self.status = 'started'
      self.newest_mkv_file_path = nil
    end

    def run_time
      return 0 if started_at.nil? || completed_at.nil?

      completed_at - started_at
    end

    def mkv(title: 'all')
      source = Config.configuration.disk_source
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
      Thread.report_on_exception = true if Thread.respond_to?(:report_on_exception)
      current_mkv_files = mkv_files
      Logger.debug(current_mkv_files.join("\n"))
      response = Open3.popen2e({}, mkv(title: title)) do |stdin, std_out_err, wait_thr|
        stdin.close
        Thread.new do
          while raw_line = std_out_err.gets
            semaphore.synchronize { process_progress_from(raw_line) }
          end
        end.join
        wait_thr.value
      end
      self.newest_mkv_file_path = (mkv_files - current_mkv_files).first
      Logger.debug(newest_mkv_file_path)
      response
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
