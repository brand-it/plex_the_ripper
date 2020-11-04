# frozen_string_literal: true

class ApplicationWorker
  include Concurrent::Async
  extend Dry::Initializer
  class Job
    extend Dry::Initializer
    param :worker, optional: true
    param :process, Types.Instance(Concurrent::IVar), default: -> { Concurrent::IVar.new }
    delegate :fulfilled?, to: :process

    def pending?
      worker && process.pending?
    end
  end

  class << self
    def perform(*args)
      return if job.pending?

      new(*args).tap do |worker|
        ApplicationWorker.jobs[self] = Job.new(worker, worker.async.call)
      end
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

  def job
    self.class.job
  end
end
