# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def perform
    broadcast_progress(in_progress_component('Scan Plex...', 50, show_percentage: false))
    plex_movies.map do |blob|
      blob.update!(video: find_or_create_video!(blob))
      self.completed += 1
      percent_completed = (completed / plex_movies.size.to_f * 100)
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

  def last_sync
    @last_sync ||= Video.maximum(:synced_on)
  end

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

  def search_for_movie(blob) # rubocop:disable Metrics/CyclomaticComplexity
    options = { query: blob.parsed_dirname.title, year: blob.parsed_dirname.year }.compact
    dirname = TheMovieDb::Search::Movie.new(**options) if options[:query].present?

    options = { query: blob.parsed_filename.title, year: blob.parsed_filename.year }.compact
    filename = TheMovieDb::Search::Movie.new(**options) if options[:query].present?

    dirname&.results&.dig('results', 0, 'id') || filename&.results&.dig('results', 0, 'id')
  end

  def search_for_tv_show(blob); end

  def find_or_create_video!(blob)
    the_movie_db_id = search_for_video(blob)
    return if the_movie_db_id.nil?

    Video.find_or_initialize_by(the_movie_db_id:).tap do |m|
      m.subscribe(TheMovieDb::VideoListener.new)
      m.save!
    end
  end

  def plex_movies
    @plex_movies ||= Ftp::VideoScannerService.call.movies
  end

  attr_writer :completed
end
