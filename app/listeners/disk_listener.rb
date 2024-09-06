# frozen_string_literal: true

class DiskListener
  extend Dry::Initializer
  include CableReady::Broadcaster
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include SlackUtility
  include ActionView::Helpers::UrlHelper
  delegate :job_url, to: 'Rails.application.routes.url_helpers'

  delegate :render, to: :ApplicationController

  def disk_ejecting(disk)
    cable_broadcast(message: "Ejecting Disk #{disk.name}")
  end

  def disk_ejected(disk)
    message = "Disk Ejected #{disk.name} - Ready for new disk"
    notify_slack(message)
    cable_broadcast(message:)
  end

  def disk_eject_failed(disk, exception)
    message = "Failed to eject #{disk.name} - #{exception.message}"
    notify_slack(message)
    cable_broadcast(message:)
  end

  def disk_loading(_)
    cable_broadcast
  end

  def disk_loaded(disk)
    return reload_page! unless (video = Video.auto_start.first)

    info_disk_titles = rip_disk_titles(disk, video)
    return reload_page! if info_disk_titles.empty?

    job = RipWorker.perform_async(
      disk_id: disk.id,
      disk_title_ids: info_disk_titles.map { _1.disk_title.id },
      extra_types: info_disk_titles.map(&:extra_type)
    )
    if job
      video.update!(auto_start: false)
      redirect_to_job(job)
    else
      reload_page!
    end
  end

  private

  def redirect_to_job(job)
    cable_ready[BroadcastChannel.channel_name].redirect_to(url: job_url(job))
    cable_ready.broadcast
  end

  def rip_disk_titles(disk, video)
    return [] unless video.is_a?(Movie)

    MovieDiskTitleSelectorService.call(movie: video, disk:).select do |info|
      info.disk_title.update!(video:) if info.extra_type.present?
      info.extra_type.present?
    end
  end

  def cable_broadcast(message: nil)
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
end
