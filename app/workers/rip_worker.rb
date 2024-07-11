# frozen_string_literal: true

class RipWorker < ApplicationWorker
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

  delegate :movie_path, :tv_season_path, to: 'Rails.application.routes.url_helpers'

  option :disk_id, Types::Integer
  option :disk_title_ids, Types::Array.of(Types::Integer)

  def perform
    if create_mkvs.all?(&:success?)
      EjectDiskService.call(disk)
      redirect_to_season_or_movie
    else
      reload_page!
    end
  end

  private

  def create_mkvs
    disk_titles.filter_map do |disk_title|
      progress_listener = MkvProgressListener.new(job:)
      result = CreateMkvService.call(disk_title:, progress_listener:)
      job.save!
      notify_slack!(disk_title)
      upload_mkv(disk_title)
      result
    end
  end

  def notify_slack!(disk_title)
    notifier = ::Slack::Notifier.new Slack::Config.newest.settings_webhook_url,
                                     channel: Slack::Config.newest.settings_channel
    if disk_title.video.is_a?(Movie)
      notifier.post text: "Processed #{disk_title.video.title}"
    elsif disk_title.video.is_a?(Tv)
      episode = disk_title.episode
      season = episode.season
      notifier.post text: "Processed #{disk_title.video.title} S#{season.season_number}E#{episode.episode_number} " \
                          "- #{episode.name}"
    end
  end

  def reload_page!
    cable_ready[BroadcastChannel.channel_name].reload
    cable_ready.broadcast
  end

  def redirect_to_season_or_movie
    reload_page! if redirect_url.blank?
    cable_ready[BroadcastChannel.channel_name].redirect_to(url: redirect_url)
    cable_ready.broadcast
  end

  def redirect_url # rubocop:disable Metrics/AbcSize
    if disk.video.is_a?(Movie)
      movie_path(disk.video)
    elsif disk.video.is_a?(Tv)
      tv_season_path(disk.episode.season.tv, disk.episode.season)
    end
  end

  def upload_mkv(disk_title)
    UploadWorker.perform_async(disk_title_id: disk_title.id)
  end

  def disk
    @disk ||= Disk.find(disk_id)
  end

  def disk_titles
    @disk_titles ||= disk.disk_titles.where(id: disk_title_ids)
  end
end
