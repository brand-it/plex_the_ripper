# frozen_string_literal: true

class MkvProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

  delegate :job_path, to: 'Rails.application.routes.url_helpers'
  delegate :render, to: :ApplicationController

  attr_reader :title, :message, :completed

  option :job, Types.Instance(Job)

  def call(mkv_message) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    case mkv_message
    when MkvParser::PRGV
      job.metadata['completed'] ||= 0.0
      job.metadata['completed'] = percentage(mkv_message.current, mkv_message.pmax)
      update_progress_bar
    when MkvParser::PRGT, MkvParser::PRGC
      job.metadata['title'] = mkv_message.name
    when MkvParser::MSG
      store_message(mkv_message.message)
      update_message_component
    end

    update_job!
  end

  def store_message(mkv_message)
    return if mkv_message.blank?

    job.metadata['message'] ||= []
    job.metadata['message'] << mkv_message
    job.metadata['message'].compact_blank!
  end

  def percentage(completed, total)
    return 0 if total.to_i.zero?

    percent = completed / total
    return 0 if percent.nan?

    (percent * 100).round(2)
  end

  def update_job!
    return if next_update.future?

    job.save!
    @next_update = nil
  end

  def update_message_component
    component = JobMessageComponent.new(job:)
    cable_ready[BroadcastChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end

  def update_progress_bar
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
    @next_update = nil
  end

  def eta # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return if job.metadata['completed'].to_f >= 100.0

    percentage_completed = job.metadata['completed'].to_f
    elapsed_time = Time.current - job.started_at

    total_time_estimated = elapsed_time / (percentage_completed / 100)
    remaining_time = total_time_estimated - elapsed_time

    eta = Time.current + remaining_time

    distance_of_time_in_words(eta, Time.current)
  rescue StandardError => e
    Rails.logger.debug { "#{e.message} #{job.started_at} #{job.metadata['completed']}" }
    Rails.logger.debug { e.backtrace.join("\n") }
    nil
  end

  def component # rubocop:disable Metrics/MethodLength
    progress_bar = render(
      ProgressBarComponent.new(
        model: DiskTitle,
        completed: job.metadata['completed'],
        status: :info,
        message: job.metadata['title'],
        eta:
      ), layout: false
    )
    component = ProcessComponent.new(worker: RipWorker)
    component.with_body { progress_bar }
    component.with_link { link_to 'View Details', job_path(job) }
    component
  end

  def next_update
    @next_update ||= 1.second.from_now
  end
end
