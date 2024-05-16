# frozen_string_literal: true

class ApplicationWorker
  include CableReady::Broadcaster

  extend Dry::Initializer
  delegate :render, to: :ApplicationController

  class << self
    def perform_async(**args)
      found_job = job
      return unless found_job.new_record?

      Rails.logger.info "Enqueuing job: #{found_job.name} with arguments: #{args}"
      found_job.update!(arguments: args)
    end

    def job
      Job.sort_by_created_at.active.find_or_initialize_by(name: to_s)
    end

    def process_work # rubocop:disable Metrics/AbcSize
      job = Job.enqueued.sort_by_created_at.first
      return if job.nil? || threads[job.id]&.alive?

      ApplicationWorker.threads[job.id] = Thread.current
      Rails.logger.info "Processing job: #{job.name} with arguments: #{job.arguments}"
      job.perform
      ApplicationWorker.threads.delete(job.id)
    end

    # Stores the thread that this current worker is running
    def threads
      @threads ||= {}
    end
  end

  def enqueue?
    true # Override in subclass to determine if the job should be enqueued
  end

  private

  def job
    self.class.job
  end
end
