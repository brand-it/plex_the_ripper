# frozen_string_literal: true

class CleanupJobWorker < ApplicationWorker
  def enqueue?
    Job.count > 100
  end

  def perform
    Job.order(created_at: :desc).offset(100).in_batches(of: 10).destroy_all
  end
end
