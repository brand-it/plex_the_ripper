# frozen_string_literal: true

class ApplicationWorker
  include CableReady::Broadcaster

  extend Dry::Initializer
  delegate :render, to: :ApplicationController

  option :job, Types.Instance(Job)

  class << self
    def perform_async(**args)
      found_job = find_or_create_job(**args)
      return unless found_job.new_record?
      return unless found_job.worker&.enqueue?

      found_job.save!
      Rails.logger.info("#{found_job.worker.class}.perform_async(#{found_job.id})")
      semaphore.synchronize { enqueued_jobs.add(found_job.id) }

      found_job
    end

    def find_or_create_job(**args)
      Job.sort_by_created_at.active.find_or_initialize_by(name: to_s, arguments: args)
    end

    def process_work
      id = take_job_id
      return if id.nil?

      Job.find_by(id:)&.perform
    end

    # Stores the thread that this current worker is running
    def threads
      @@threads ||= {} # rubocop:disable Style/ClassVars
    end

    def enqueued_jobs
      @@enqueued_jobs ||= Job.enqueued.pluck(:id).to_set # rubocop:disable Style/ClassVars
    end

    def take_job_id
      semaphore.synchronize do
        job_id = enqueued_jobs.first
        enqueued_jobs.delete(job_id) if job_id.present?
        job_id
      end
    end

    def semaphore
      @@semaphore ||= Thread::Mutex.new # rubocop:disable Style/ClassVars
    end
  end

  def broadcast_component(component)
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def enqueue?
    raise "#enqueue? needs to be defined in #{self.class}"
  end
end
