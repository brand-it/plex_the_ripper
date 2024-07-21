# frozen_string_literal: true

class DiskListener
  extend Dry::Initializer
  include CableReady::Broadcaster
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include SlackUtility

  delegate :render, to: :ApplicationController

  def disk_ejecting(disk)
    cable_broadcast("Ejecting Disk #{disk.name}", :info)
  end

  def disk_ejected(disk)
    message = "Disk Ejected #{disk.name} - Ready for new disk"
    notify_slack(message)
    cable_broadcast(message)
  end

  def disk_eject_failed(disk, exception)
    message = "Failed to eject #{disk.name} - #{exception.message}"
    notify_slack(message)
    cable_broadcast(message)
  end

  def disk_loading(disk)
    message = disk.name ? "Loading #{disk.name} ..." : 'Loading the disk ...'
    cable_broadcast(message)
  end

  def disk_loaded(disk)
    cable_broadcast
  end

  private

  def cable_broadcast(message = nil)
    component = LoadDiskProcessComponent.new(message:)

    cable_ready[BroadcastChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
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

  def redirect_url
    if disk.video.is_a?(Movie)
      movie_url(disk.video)
    elsif disk.video.is_a?(Tv)
      tv_season_url(disk.episode.season.tv, disk.episode.season)
    end
  end
end
