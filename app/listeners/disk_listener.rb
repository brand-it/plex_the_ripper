# frozen_string_literal: true

class MkvProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include SlackUtility

  option :disk, Types.Instance(::Disk)

  delegate :render, to: :ApplicationController

  def disk_ejecting
    cable_broadcast("Ejecting Disk #{disk.name}", :info)
  end

  def disk_ejected
    message = "Disk Ejected #{disk.name} - Ready for new disk"
    notify_slack(message)
    cable_broadcast(message, :success)
  end

  def disk_eject_failed(exception)
    message = "Failed to eject #{disk.name} - #{exception.message}"
    notify_slack(message)
    cable_broadcast(message, :error)
  end

  private

  def cable_broadcast(message, status)
    progress_bar = render(
      ProgressBarComponent.new(model: Video, show_percentage: false, status:, message:), layout: false
    )
    component = ProcessComponent.new(worker: LoadDiskWorker)
    component.with_body { progress_bar }
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
