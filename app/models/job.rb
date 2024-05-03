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
  COMPLETED_STATUSES = %i[succeeded errored cancelled].freeze
  enum(:status, STATUSES.index_with(&:to_s))

  serialize :backtrace, coder: YAML
  serialize :arguments, coder: JSON

  validates :name, presence: true
  validates :status, presence: true
  validates :error_message, presence: true, if: :errored?

  before_save :set_ended_at, if: :status_changed?
  before_save :set_started_at, if: :status_changed?

  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :completed, -> { where(status: COMPLETED_STATUSES) }
  scope :sort_by_created_at, -> { order(created_at: :desc) }

  def perform # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    return if active?

    begin
      worker = name.constantize.new(*params, **options)
      raise NotImplementedError, "#{name} must implement #perform method" unless worker.respond_to?(:perform)

      ApplicationWorker.workers[id] = Thread.current
      update!(status: :running)
      worker.perform
      update!(status: :succeeded)
    rescue StandardError => e
      update!(
        error_message: e.message,
        error_class: e.class.name,
        backtrace: e.backtrace,
        status: :errored
      )
    end
  end

  def worker
    ApplicationWorker.workers[id]
  end

  def active?
    ACTIVE_STATUSES.include?(status)
  end

  private

  def params
    arguments.try(:first) || []
  end

  def options
    (arguments.try(:last) || {}).symbolize_keys
  end

  def set_ended_at
    return unless COMPLETED_STATUSES.include?(status) || STOPPING_STATUSES.include?(status)

    self.ended_at ||= Time.current
  end

  def set_started_at
    return unless ACTIVE_STATUSES.include?(status)

    self.started_at ||= Time.current
  end
end
