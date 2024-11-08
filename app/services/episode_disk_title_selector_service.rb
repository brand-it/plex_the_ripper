# frozen_string_literal: true

class EpisodeDiskTitleSelectorService < ApplicationService
  DEFAULT_RANGE = (60 * 3).seconds # 3 minutes

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
    return if uploaded?(episode) || ripped?(episode)

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
    uploaded_episodes_numbers.any? { _1.include?(episode.episode_number) } ||
      episode.ripped_disk_titles.any? { _1&.video_blob&.uploaded? } ||
      episode.video_blobs.any?(&:uploaded?)
  end

  def ripped?(episode)
    ripped_episodes_numbers.any? { _1.include?(episode.episode_number) } ||
      episode.ripped_disk_titles.any?
  end

  def within_range?(episode, disk_title)
    runtime_range(episode)&.include?(disk_title.duration)
  end

  def runtime_range(episode)
    runtime = episode.tv.duration_stats.weighted_average || episode.runtime
    range = episode.tv.duration_stats.interquartile_range || DEFAULT_RANGE
    return if runtime.nil?

    (runtime - range)...(runtime + range)
  end

  def selected_disk_titles
    @selected_disk_titles ||= []
  end

  def uploaded_episodes_numbers
    @uploaded_episodes_numbers ||= episodes.flat_map do |episode|
      episode.uploaded_video_blobs.filter_map(&:episode_numbers)
    end
  end

  def ripped_episodes_numbers
    @ripped_episodes_numbers ||= episodes.flat_map do |episode|
      episode.ripped_disk_titles.filter_map(&:episode_numbers)
    end
  end

  def sort_episodes
    @sort_episodes ||= episodes.sort_by(&:episode_number)
  end
end
