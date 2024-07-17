# frozen_string_literal: true

class MkvProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include SlackUtility

  NOTIFICATION_TITLE = 'Saving to MKV file'

  delegate :job_path, to: 'Rails.application.routes.url_helpers'
  delegate :render, to: :ApplicationController

  option :disk_title, Types.Instance(DiskTitle)
  option :job, Types.Instance(Job)

  attr_reader :video_blob

  def start(video_blob)
    @video_blob = video_blob
    job.metadata['completed'] = 0.0
    notify_slack("Started #{video_blob.title}") if video_blob.feature_films?
    update_progress_bar
    job.save!
  end

  def success(video_blob)
    @video_blob = video_blob
    job.metadata['completed'] = 100.0
    notify_slack("Completed #{video_blob.title}") if video_blob.feature_films?
    update_progress_bar
    job.save!
  end

  def failure(video_blob)
    @video_blob = video_blob
    job.metadata['completed'] = 0.0
    notify_slack("Failure #{video_blob.title}")

    update_progress_bar
    job.save!
  end

  def raw_line(mkv_message, video_blob) # rubocop:disable Metrics/MethodLength
    @video_blob = video_blob
    case mkv_message
    when MkvParser::PRGV
      job.metadata['completed'] ||= 0.0
      job.metadata['completed'] = percentage(mkv_message.current, mkv_message.pmax)
    when MkvParser::PRGT, MkvParser::PRGC
      job.metadata['title'] = "#{video_blob.title}\n#{mkv_message.name}"
    when MkvParser::MSG
      store_message(mkv_message.message)
      update_message_component
    end

    update_job!
  end

  private

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

    update_progress_bar
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
  end

  def eta # rubocop:disable Metrics/MethodLength
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
