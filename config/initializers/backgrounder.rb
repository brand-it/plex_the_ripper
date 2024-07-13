# frozen_string_literal: true

# Cron Scheduler using a background thread
#
# This is a simple example of how to create a cron scheduler using a background thread.
#

class Backgrounder
  TOTAL_WORKERS = 3

  CRON_TASKS = {
    'ContinueUploadWorker' => 60.seconds.to_i,
    'ScanPlexWorker' => 10.minutes.to_i,
    'LoadDiskWorker' => 5.seconds.to_i,
    'CleanupJobWorker' => 1.minute.to_i
  }.freeze

  class << self
    # kick off the threads asynchronusly
    # so that the main thread can continue
    def start
      Rails.logger.info "Starting background #{TOTAL_WORKERS} workers and scheduler"
      fix_broken_jobs
      @threads = (worker_threads + [scheduled_thread])
      @threads.each(&:run)
    end

    def shutdown
      Rails.logger.info "Shutting down background #{TOTAL_WORKERS} workers and scheduler"
      Timeout.timeout(5) do
        Array.wrap(@threads).each(&:stop)
      end
    rescue StandardError => e
      Rails.logger.warn "Warning: #{e.message}"
      Array.wrap(@threads).each(&:kill)
    end

    private

    def fix_broken_jobs
      Job.hanging.find_each do |job|
        next if ApplicationWorker.threads[job.id].present?

        job.update!(status: :errored, error_message: 'Job was marked as stopping but no worker was found to process it')
      end
    end

    def schedule
      @schedule ||= CRON_TASKS.to_h do |task, _|
        [task, Time.current.to_i]
      end
    end

    def worker_threads
      TOTAL_WORKERS.times.map do
        threaded_loop { ApplicationWorker.process_work }
      end
    end

    def scheduled_thread
      threaded_loop do
        CRON_TASKS.each do |task, duration|
          next if Time.current.to_i < schedule[task]

          Object.const_get(task).perform_async
          schedule[task] = Time.current.to_i + duration
        end
      end
    end

    def threaded_loop(&block)
      Thread.new do
        loop do
          block.call
          sleep 1
        rescue StandardError => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          nil
        end
      end
    end
  end
end
