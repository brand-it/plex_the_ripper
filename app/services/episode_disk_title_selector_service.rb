# frozen_string_literal: true

class EpisodeDiskTitleSelectorService < ApplicationService
  Info = Data.define(
    :disk_title,
    :episode,
    :ripped?,
    :uploaded?
  )

  option :disk, Types.Instance(Disk).optional
  option :episodes, Types::Coercible::Array.of(Types.Instance(Episode))

  def call
    sort_episodes.map do |episode|
      Info.new(
        episode_disk_title(episode),
        episode,
        episode.ripped_disk_titles.any?,
        uploaded?(episode)
      )
    end
  end

  private

  def episode_disk_title(episode)
    return if disk.nil?
    return if selected_episodes.include?(episode)

    disk.disk_titles.find { within_range?(episode, _1) && selected_disk_titles.exclude?(_1) }.tap do |disk_title|
      selected_disk_titles.append(disk_title) if disk_title
    end
  end

  def select_episode(disk_title)
    episode = sort_episodes.find { selected_episodes.exclude?(_1) && within_range?(_1, disk_title) }
    selected_episodes.append(episode)
    episode
  end

  def uploaded?(episode)
    episode.ripped_disk_titles.any? { _1&.video_blob&.uploaded? }
  end

  def within_range?(episode, disk_title)
    episode.runtime_range.include?(disk_title.duration)
  end

  def selected_disk_titles
    @selected_disk_titles ||= []
  end

  def selected_episodes
    @selected_episodes ||= episodes.select do |episode|
      episode.ripped_disk_titles.any? || episode.uploaded_video_blobs.any?
    end
  end

  def sort_episodes
    @sort_episodes ||= episodes.sort_by(&:episode_number)
  end
end
