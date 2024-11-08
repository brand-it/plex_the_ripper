# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def enqueue?
    true
  end

  def perform
    broadcast_component(ScanPlexProcessComponent.new)
    job.add_message('Starting Processing Video Blobs')
    update_message_component
    video_blobs.each do |blob|
      blob.video = find_or_create_video(blob)
      blob.episode = search_for_episode(blob, blob.video)
      blob.episode_last = search_for_episode(blob, blob.video, last: true)
      unless blob.save
        job.add_message("Failed create video from #{blob.key}")
        job.add_message(blob.errors.full_messages)
      end
      self.completed += 1
      job.completed = (completed / video_blobs.size.to_f * 100)
      next if next_update.future?

      job.save!
      update_message_component
      broadcast_component(ScanPlexProcessComponent.new)
      @next_update = 1.second.from_now
    end
    existing_ids = video_blobs.map(&:id).compact
    VideoBlob.not_uploaded.in_batches do |batch|
      VideoBlob.where(id: batch.map(&:id) - existing_ids).find_each do |blob|
        job.add_message("Destroyed #{blob.key}")
        blob.destroy
        update_message_component
      end
    end
    Video.includes(:video_blobs).find_each do |video|
      if video.video_blobs.empty?
        video.destroy
        job.add_message("Destroyed #{video.plex_name}")
        update_message_component
      end
    end
    job.update!(completed: 100)
    broadcast_component(ScanPlexProcessComponent.new)
    update_message_component
    job
  end

  private

  def update_message_component
    component = JobMessageComponent.new(job:)
    cable_ready[JobChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end

  def completed
    @completed ||= 0
  end

  def search_for_movie(blob)
    options = { query: blob.parsed_title, year: blob.parsed_year }.compact
    search = TheMovieDb::Search::Movie.new(**options) if options[:query].present?

    search&.results&.dig('results', 0, 'id')
  end

  def search_for_tv_show(blob)
    options = { query: blob.parsed_title, year: blob.parsed_year }.compact
    search = TheMovieDb::Search::Tv.new(**options) if options[:query].present?

    search&.results&.dig('results', 0, 'id')
  end

  def search_for_episode(blob, video, last: false)
    return unless video.is_a?(::Tv)

    season = video.seasons.find { _1.season_number == blob.parsed_season }
    return if season.nil?

    season.subscribe(TheMovieDb::EpisodesListener.new)
    season.save!
    episode_number = last ? blob.parsed_episode_last : blob.parsed_episode
    season.episodes.find { _1.episode_number == episode_number }
  end

  def find_or_create_video(blob)
    the_movie_db_id = if blob.movie?
                        search_for_movie(blob)
                      elsif blob.tv_show?
                        search_for_tv_show(blob)
                      end
    return if the_movie_db_id.nil?

    find_or_initialize_video(blob, the_movie_db_id).tap do |m|
      m.subscribe(TheMovieDb::VideoListener.new)
      m.save!
    end
  end

  def find_or_initialize_video(blob, the_movie_db_id)
    model = if blob.tv_show?
              Tv
            elsif blob.movie?
              Movie
            end
    videos.find { _1.the_movie_db_id == the_movie_db_id } ||
      model&.new(the_movie_db_id:)&.tap { videos.push(_1) }
  end

  def videos
    @videos ||= Video.all.to_a
  end

  def video_blobs
    @video_blobs ||= Ftp::VideoScannerService.call
  end

  def next_update
    @next_update ||= 1.second.from_now
  end

  attr_writer :completed
end
