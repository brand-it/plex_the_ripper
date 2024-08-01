# frozen_string_literal: true

class MkvDiskLoadListener
  extend Dry::Initializer
  include CableReady::Broadcaster
  include SlackUtility

  delegate :render, to: :ApplicationController

  option :job, Types.Instance(Job)

  attr_reader :video_blob

  def mkv_start(video_blob)
    @video_blob = video_blob
    job.update!(completed: 0.0, title: video_blob&.title)
    update_progress_bar
  end

  def mkv_success(video_blob)
    @video_blob = video_blob
    job.update!(completed: 100)
    update_progress_bar
  end

  def mkv_failure(video_blob, exception = nil)
    @video_blob = video_blob
    job.completed = 0.0
    backtrace = exception&.backtrace&.map do |trace|
      trace.gsub(Rails.root.to_s, 'ROOT').strip
    end || []

    if exception
      job.title = exception.message
      job.add_message(exception.message)
      backtrace.each { job.add_message(_1) }
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

  def mkv_waiting
    job.add_message('waiting')
    job.save!
    update_progress_bar
  end

  def mkv_raw_line(mkv_message)
    case mkv_message
    when MkvParser::PRGV
      job.completed = percentage(mkv_message.current, mkv_message.pmax)
    when MkvParser::PRGT, MkvParser::PRGC
      job.title = "#{video_blob.title}\n#{mkv_message.name}"
    when MkvParser::MSG
      job.add_message(mkv_message.message)
      update_message_component
    end

    update_job!
  end

  private

  def reload_page!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
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
    component = LoadDiskProcessComponent.new
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def next_update
    @next_update ||= 1.second.from_now
  end
end
