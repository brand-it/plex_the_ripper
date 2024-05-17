# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id            :integer          not null, primary key
#  arguments     :text
#  backtrace     :text
#  ended_at      :datetime
#  error_class   :string
#  error_message :string
#  metadata      :text             default({}), not null
#  name          :string           not null
#  started_at    :datetime
#  status        :string           default("enqueued"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Job < ApplicationRecord
  STATUSES = [
    :enqueued,    # The task has been enqueued by the user.
    :running,     # The task is being performed by a job worker.
    :succeeded,   # The task finished without error.
    :cancelling,  # The task has been told to cancel but is finishing work.
    :cancelled,   # The user explicitly halted the task's execution.
    :interrupted, # The task was interrupted by the job infrastructure.
    :pausing,     # The task has been told to pause but is finishing work.
    :paused,      # The task was paused in the middle of the run by the user.
    :errored      # The task code produced an unhandled exception.
  ].freeze
  ACTIVE_STATUSES = %i[
    enqueued
    running
    paused
    pausing
    cancelling
    interrupted
  ].freeze
  STOPPING_STATUSES = %i[
    pausing
    cancelling
    cancelled
  ].freeze
  HANGING_STATUSES = %i[
    enqueued
    running
    pausing
    cancelling
  ].freeze
  COMPLETED_STATUSES = %i[succeeded errored cancelled].freeze
  enum(:status, STATUSES.index_with(&:to_s))

  serialize :arguments, coder: JSON
  serialize :backtrace, coder: YAML
  serialize :metadata, coder: JSON

  validates :name, presence: true
  validates :status, presence: true
  validates :error_message, presence: true, if: :errored?

  before_save :set_ended_at, if: :status_changed?
  before_save :set_started_at, if: :status_changed?
  before_save :bust_cache, if: :status_changed?

  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :completed, -> { where(status: COMPLETED_STATUSES) }
  scope :sort_by_created_at, -> { order(created_at: :desc) }
  scope :hanging, -> { where(status: HANGING_STATUSES) }

  def perform
    return unless enqueued?

    raise NotImplementedError, "#{name} must implement #perform method" unless worker.respond_to?(:perform)

    update!(status: :running)
    worker.perform
    update!(status: :succeeded)
  rescue StandardError => e
    record_exception!(e)
  end

  def worker
    @worker ||= name.constantize.new(**arguments.symbolize_keys.merge(job: self))
  rescue StandardError => e
    record_exception!(e)
    nil
  end

  def record_exception!(exception)
    update!(
      error_message: exception.message,
      error_class: exception.class.name,
      backtrace: exception.backtrace,
      status: :errored
    )
  end

  def backtrace
    super || []
  end

  def active?
    ACTIVE_STATUSES.include?(status.to_sym) && id.present?
  end

  private

  def bust_cache
    Rails.cache.delete('active_jobs')
  end

  def set_ended_at
    return unless COMPLETED_STATUSES.include?(status.to_sym) || STOPPING_STATUSES.include?(status.to_sym)

    self.ended_at ||= Time.current
  end

  def set_started_at
    return unless ACTIVE_STATUSES.include?(status.to_sym)

    self.started_at ||= Time.current
  end
end
