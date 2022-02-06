# frozen_string_literal: true

class ApplicationWorker
  include CableReady::Broadcaster

  extend Dry::Initializer
  delegate :render, to: :ApplicationController

  class Job
    extend Dry::Initializer

    option :thread, Types.Instance(Thread), optional: true
    option :worker, optional: true

    attr_accessor :exception

    delegate :status, :backtrace, to: :thread

    def pending?
      worker.present? && thread&.alive?
    end

    def logs
      @logs ||= []
    end

    def log(message)
      logs << message
    end
  end

  class << self
    def perform_async(...)
      return if job.pending?

      ApplicationWorker.jobs[self] = new(...).perform_async
    end

    def job
      ApplicationWorker.jobs[self] || Job.new
    end

    def jobs
      @jobs ||= {}.compare_by_identity
    end

    def find(key)
      jobs[key.constantize]
    end
  end

  def perform_async
    Job.new(worker: self, thread: async)
  end

  private

  def async
    raise NotImplementedError, 'You must implement the `perform` method' unless respond_to?(:perform)

    thread = Thread.new do
      perform
    rescue StandardError => e
      job.exception = e
    end
    thread.report_on_exception = true
    thread.abort_on_exception = true
    thread.run
    thread
  end

  def job
    self.class.job
  end
end
