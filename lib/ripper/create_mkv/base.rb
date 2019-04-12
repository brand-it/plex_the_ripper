# frozen_string_literal: true

class CreateMKV
  class Base
    include TimeHelper
    include HumanizerHelper

    attr_accessor :run_time, :directory, :started_at, :completed_at, :status, :notification_percentages
    def initialize
      self.started_at = nil
      self.completed_at = nil
      self.status = 'ready'
      self.directory = AskForFilePathBuilder.path
      self.notification_percentages = [5.0, 25.0, 50.0, 75.0, 90.0, 95.0, 99.0]
      create_directory_path
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

    # Define this method on each child class. If not defined that is ok. We will just assume you wanted
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

    def notify_slack_success
      return unless success?

      Notification.slack(
        "Finished ripping #{humanize_disk_info}",
        "It took a total of #{human_seconds(run_time)} to rip #{Config.configuration.video_name}",
        message_color: 'green'
      )
    end

    def notify_slack_failure
      return unless failed?

      Notification.slack(
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
      self.status = 'success'
    end

    def failure!
      self.completed_at = Time.now
      self.status = 'failed'
    end

    def start!
      self.started_at = Time.now
      self.status = 'started'
    end

    def finished!
      return unless success?

      self.completed_at = Time.now
    end

    def run_time
      return 0 if started_at.nil? || completed_at.nil?

      completed_at - started_at
    end

    def mkv(title: 'all')
      [
        Shellwords.escape(Config.configuration.makemkvcon_path),
        'mkv',
        Config.configuration.disk_source,
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
      progressbar = ProgressBar.create(format: '%e |%b>>%i| %p%% %t')
      current_progress = 0
      current_title = nil
      type = ''
      values = ''

      Logger.debug(mkv(title: title))
      Open3.popen2e(
        {}, mkv(title: title)
      ) do |stdin, std_out_err, wait_thr|
        stdin.close
        Thread.new do
          while raw_line = std_out_err.gets # rubocop:disable Lint/AssignmentInCondition
            Logger.debug(raw_line.strip)
            semaphore.synchronize do
              type, values = raw_line.strip.split(':')

              if type == 'PRGV'
                notify_slack_of_progress(progressbar) if current_title == 'Saving to MKV file'
                _current, progress, max_progress = values.split(',').map(&:to_i)
                current_progress = increment_progress(
                  max_progress, progress, progressbar, current_progress
                )
              elsif type == 'PRGC' && current_title != values.split(',').last.strip
                current_title = values.split(',').last.strip.delete('"')
                reset_progress(progressbar, current_title)
              end
            end
          end
          progressbar.finish
        end.join
        wait_thr.value
      end
    end

    def notify_slack_of_progress(progressbar)
      return if notification_percentages.first > progressbar.to_h['percentage']

      notification_percentages.shift

      Notification.slack(
        "Progress Update #{Config.configuration.video_name}",
        progressbar.to_s('%t %p% %E | Time Elapsed %a'),
        message_color: 'green'
      )
    end

    def increment_progress(max_progress, progress, progressbar, current_progress)
      progressbar.total = max_progress if max_progress != progressbar.total
      progressbar.progress += (progress - current_progress)
      progress
    end

    def reset_progress(progressbar, current_title)
      progressbar.finish
      progressbar.reset
      progressbar.title = current_title
      progressbar.start
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
        Logger.error(
          "Could not rip file #{Config.configuration.video_name}, #{mkv(title: title)}"
        )
        notify_slack_failure
        failure!
      end
    end
  end
end
