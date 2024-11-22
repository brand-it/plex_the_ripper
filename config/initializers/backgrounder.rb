# frozen_string_literal: true

# Cron Scheduler using a background thread
#
# This is a simple example of how to create a cron scheduler using a background thread.
#

class Backgrounder
  class Manager
    def thread(&block)
      @thread ||= Thread.new do
        loop do
          block.call(self)
          sleep 0.1
        rescue StandardError => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          nil
        ensure
          self.current_job = nil
        end
      end
    end

    def stop
      Thread.stop(@thread)
    end

    def run
      @thread.run
    end

    def kill
      Thread.kill(@thread)
    end

    attr_accessor :current_job
  end
  TOTAL_MANAGERS = 3

  CRON_TASKS = {
    'ContinueUploadWorker' => 60.seconds.to_i,
    'ScanPlexWorker' => 1.hour.to_i,
    'LoadDiskWorker' => 5.seconds.to_i,
    'CleanupJobWorker' => 1.hour.to_i
  }.freeze

  class << self
    def managers
      Array.wrap(@managers)
    end

    def start
      Rails.logger.info "Starting background #{TOTAL_MANAGERS} managers and scheduler"
      fix_broken_jobs
      @managers = (worker_managers + [scheduled_manager])
      @managers.each(&:run)
    end

    def shutdown
      Rails.logger.info "Shutting down background #{TOTAL_MANAGERS} workers and scheduler"
      Timeout.timeout(5) do
        managers.each(&:stop)
      end
    rescue StandardError => e
      Rails.logger.warn "Warning: #{e.message}"
      managers.each(&:kill)
    end

    private

    def fix_broken_jobs
      Job.hanging.find_each do |job|
        next if managers.any? { _1.current_job&.id == job.id }

        job.update!(status: :errored, error_message: 'Job was marked as stopping but no worker was found to process it')
      end
    end

    def schedule
      @schedule ||= CRON_TASKS.to_h do |task, _|
        [task, Time.current.to_i]
      end
    end

    def worker_managers
      TOTAL_MANAGERS.times.map do
        manager = Manager.new
        manager.thread { process_work(_1) }
        manager
      end
    end

    def scheduled_manager
      manager = Manager.new
      manager.thread do |_manager|
        CRON_TASKS.each do |task, duration|
          next if Time.current.to_i < schedule[task]

          Object.const_get(task).perform_async
          schedule[task] = Time.current.to_i + duration
          sleep 0.1 # make sure we don't unique all at the same time
        end
      end
      manager
    end

    def process_work(manager)
      @manager = manager
      @manager.current_job = Job.find_by(id: take_job_id)
      return if current_job.nil?

      if current_job.name_constant.concurrently.nil? || current_job.name_constant.concurrently >= concurrent_count
        current_job.perform
      else
        add_job_id(current_job.id)
      end
    end

    def enqueued_jobs
      @enqueued_jobs ||= Job.enqueued.pluck(:id).to_set
    end

    def concurrent_count
      managers.count do |manager|
        manager.current_job&.name == @manager.current_job.name
      end
    end

    def take_job_id
      semaphore.synchronize do
        job_id = enqueued_jobs.first
        enqueued_jobs.delete(job_id) if job_id.present?
        job_id
      end
    end

    def add_job_id(id)
      semaphore.synchronize { enqueued_jobs.add(id) }
    end

    def semaphore
      @semaphore ||= Thread::Mutex.new
    end
  end
end
