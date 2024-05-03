# frozen_string_literal: true

class ApplicationWorker
  include CableReady::Broadcaster

  extend Dry::Initializer
  delegate :render, to: :ApplicationController

  class << self
    def perform_async(**args)
      Job.sort_by_created_at.active.find_or_initialize_by(name: to_s).tap do |job|
        job.update!(arguments: args)
      end
    end

    def job
      Job.sort_by_created_at.find_or_initialize_by(name: to_s)
    end

    def process_work
      job = Job.active.first
      return unless job

      job.perform
    end

    # Stores the thread that this current worker is running
    def workers
      @workers ||= {}
    end
  end

  private

  def job
    self.class.job
  end
end
