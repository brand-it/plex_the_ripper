# frozen_string_literal: true

class MkvProgressListener
  extend Dry::Initializer
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::UrlHelper
  include CableReady::Broadcaster
  include SlackUtility

  delegate :movie_url, :tv_season_url, :job_path, to: 'Rails.application.routes.url_helpers'
  delegate :render, to: :ApplicationController

  option :job, Types.Instance(Job)

  attr_reader :video_blob

  def mkv_start(video_blob)
    @video_blob = video_blob
    job.update!(title: video_blob&.title, completed: 0)
    update_progress_bar
  end

  def mkv_success(video_blob)
    @video_blob = video_blob
    job.update!(completed: 100)
    update_progress_bar
    redirect_to_season_or_movie
  end

  def mkv_failure(video_blob, exception = nil)
    @video_blob = video_blob
    job.completed = 0
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

  def mkv_raw_line(mkv_message)
    case mkv_message
    when MkvParser::PRGV
      job.completed = percentage(mkv_message.current, mkv_message.pmax)
    when MkvParser::PRGT, MkvParser::PRGC
      job.title = [video_blob&.title, mkv_message.name].compact_blank.join("\n")
    when MkvParser::MSG
      job.add_message(mkv_message.message)
      update_message_component
    end

    update_job!
  end

  private

  def redirect_to_season_or_movie
    reload_page! if redirect_url.blank?
    cable_ready[BroadcastChannel.channel_name].redirect_to(url: redirect_url)
    cable_ready.broadcast
  end

  def redirect_url
    if video_blob.video.is_a?(Movie)
      movie_url(video_blob.video)
    elsif video_blob.video.is_a?(Tv)
      tv_season_url(video_blob.episode.season.tv, video_blob.episode.season)
    end
  end

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
    component = RipProcessComponent.new
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def next_update
    @next_update ||= 1.second.from_now
  end
end
