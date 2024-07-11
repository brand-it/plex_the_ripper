# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def perform
    broadcast_progress(in_progress_component('Scan Plex...', 50, show_percentage: false))
    plex_videos.map do |blob|
      blob.video = find_or_create_video(blob)
      blob.episode = search_for_episode(blob, blob.video)
      self.completed += 1
      percent_completed = (completed / plex_videos.size.to_f * 100)
      broadcast_progress(
        in_progress_component('Updating Database...', percent_completed)
      )
    end
    broadcast_progress(completed_component)
  end

  def completed
    @completed ||= 0
  end

  private

  def broadcast_progress(component)
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def completed_component
    progress_bar = render(
      ProgressBarComponent.new(
        model: Movie,
        completed: 100,
        status: :success,
        message: 'Plex scan complete!'
      ), layout: false
    )
    component = ProcessComponent.new(worker: ScanPlexWorker)
    component.with_body { progress_bar }
    component
  end

  def in_progress_component(message, completed, show_percentage: true)
    progress_bar = render(
      ProgressBarComponent.new(
        model: Movie,
        completed:,
        status: :info,
        message: message || 'Scanning Plex...',
        show_percentage:
      ), layout: false
    )
    component = ProcessComponent.new(worker: ScanPlexWorker)
    component.with_body { progress_bar }
    component
  end

  def search_for_movie(blob)
    options = { query: blob.title, year: blob.year }.compact
    search = TheMovieDb::Search::Movie.new(**options) if options[:query].present?

    search&.results&.dig('results', 0, 'id')
  end

  def search_for_tv_show(blob)
    options = { query: blob.title, year: blob.year }.compact
    search = TheMovieDb::Search::Tv.new(**options) if options[:query].present?

    search&.results&.dig('results', 0, 'id')
  end

  def search_for_episode(blob, video)
    return unless video.is_a?(Tv)

    season = video.seasons.find { _1.season_number == blob.season }
    return if season.nil?

    season.subscribe(TheMovieDb::EpisodesListener.new)
    season.save!
    season.episodes.find { _1.episode_number == blob.episode }
  end

  def find_or_create_video(blob)
    the_movie_db_id = if blob.movie?
                        search_for_movie(blob)
                      elsif blob.tv_show?
                        search_for_tv_show(blob)
                      end
    return if the_movie_db_id.nil?

    model = if blob.tv_show?
              Tv
            elsif blob.movie?
              Movie
            else
              return
            end
    model.find_or_initialize_by(the_movie_db_id:).tap do |m|
      m.subscribe(TheMovieDb::VideoListener.new)
      m.save!
    end
  end

  def plex_videos
    @plex_videos ||= Ftp::VideoScannerService.call
  end

  attr_writer :completed
end
