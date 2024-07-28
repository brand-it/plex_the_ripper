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

  option :job, Types.Instance(Job)

  attr_reader :video_blob

  def mkv_start(video_blob)
    @video_blob = video_blob
    job.metadata['completed'] = 0.0
    update_progress_bar
    job.save!
  end

  def mkv_success(video_blob)
    @video_blob = video_blob
    job.metadata['completed'] = 100.0
    update_progress_bar
    job.save!
  end

  def mkv_failure(video_blob, exception = nil)
    @video_blob = video_blob
    job.metadata['completed'] = 0.0
    backtrace = exception&.backtrace&.map do |trace|
      trace.gsub(Rails.root.to_s, 'ROOT').strip
    end || []

    if exception
      job.metadata['title'] = exception.message
      store_message(exception.message)
      backtrace.each { store_message(_1) }
    end

    notify_slack(
      "Failure #{
        [
          video_blob.title,
          exception&.message,
          last_message,
          ("```#{backtrace.join("\n")}```" if backtrace.any?)
        ].compact_blank.join("\n")
      }"
    )
    job.save!

    update_progress_bar
    reload_page!
  end

  def mkv_raw_line(mkv_message)
    case mkv_message
    when MkvParser::PRGV
      job.metadata['completed'] ||= 0.0
      job.metadata['completed'] = percentage(mkv_message.current, mkv_message.pmax)
    when MkvParser::PRGT, MkvParser::PRGC
      job.metadata['title'] = [video_blob&.title, mkv_message.name].compact_blank.join("\n")
    when MkvParser::MSG
      store_message(mkv_message.message)
      update_message_component
    end

    update_job!
  end

  private

  def reload_page!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end

  def store_message(mkv_message)
    return if mkv_message.blank?

    job.metadata['message'] ||= []
    job.metadata['message'] << mkv_message
    job.metadata['message'].compact_blank!
  end

  def last_message
    job.metadata['message'].last
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
    cable_ready[JobChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end

  def update_progress_bar
    component = RipProcessComponent.new
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def eta
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

  def next_update
    @next_update ||= 1.second.from_now
  end
end
