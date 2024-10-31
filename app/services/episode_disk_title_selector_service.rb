# frozen_string_literal: true

class EpisodeDiskTitleSelectorService < ApplicationService
  Info = Data.define(
    :disk_title,
    :episode,
    :ripped?,
    :uploaded?
  )

  option :disk, Types.Instance(Disk)
  option :episodes, Types::Coercible::Array.of(Types.Instance(Episode))

  def call
    disk.disk_titles.map do |disk_title|
      Info.new(
        disk_title,
        select_episode(disk_title),
        ripped?(disk_title),
        uploaded?(disk_title)
      )
    end
  end

  private

  def select_episode(disk_title)
    episode = sort_episodes.find { selected_episodes.exclude?(_1) && within_range?(_1, disk_title) }
    selected_episodes.append(episode)
    episode
  end

  def ripped?(disk_title)
    ripped_disk_titles.any? { _1.filename == disk_title.filename }
  end

  def uploaded?(disk_title)
    ripped_disk_titles.find { _1.filename == disk_title.filename }&.video_blob&.uploaded? || false
  end

  def ripped_disk_titles
    @ripped_disk_titles ||= episodes.flat_map(&:ripped_disk_titles)
  end

  def within_range?(episode, disk_title)
    episode.runtime_range.include?(disk_title.duration)
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
