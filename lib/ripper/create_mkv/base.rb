class CreateMKV
  class Base
    include TimeHelper
    include HumanizerHelper

    attr_accessor :run_time, :directory, :started_at, :completed_at, :status
    def initialize
      self.started_at = nil
      self.completed_at = nil
      self.status = 'ready'
      self.directory = FilePathBuilder.path.to_s
      create_directory_path
    end

    def mkv_files
      @mkv_files ||= Dir.entries(directory).select do |episode|
        File.extname(episode) == '.mkv'
      end
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
      started_at - completed_at
    end

    def mkv(title: 'all')
      [
        Config.configuration.makemkvcon_path,
        'mkv',
        Config.configuration.disk_source,
        title,
        directory,
        "--minlength=#{Config.configuration.minlength}",
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
      max = 0
      type = ''
      values = ''

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
                _current, progress, max_progress = values.split(',').map(&:to_i)
                increment_progress(max_progress, progress, progressbar, current_progress)
              elsif type == 'PRGC' && current_title != values.split(',').last.strip
                current_title = values.split(',').last.strip
                reset_progress(progressbar, current_title)
              end
            end
          end
          progressbar.finish
        end.join
        wait_thr.value
      end
    end

    def increment_progress(max_progress, progress, progressbar, current_progress)
      progressbar.total = max_progress if max_progress != progressbar.total
      progressbar.progress += (progress - current_progress)
      current_progress = progress
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

    def process_status!(status)
      if status.success? && Dir[directory + '/*'].any?
        success!
      else
        Logger.error(
          "Could not rip file #{Config.configuration.video_name}"
        )
        notify_slack_failure
        failure!
      end
    end
  end
end
