# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def perform
    plex_movies.map do |blob|
      blob.update!(video: create_movie!(blob))
      job.log("Updated #{blob.filename}")
      self.completed += 1
      broadcast_progress(in_progress_component(blob&.video&.plex_name))
    end
    broadcast_progress(completed_component)
  end

  private

  def broadcast_progress(component)
    cable_ready[DiskTitleChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def completed_component
    ProcessComponent.new worker: ScanPlexWorker do |c|
      c.with_body do
        ProgressBarComponent.new \
          model: Movie,
          completed: 100,
          status: :success,
          message: 'Plex scan complete!'
      end
    end
  end

  def in_progress_component(message)
    ProcessComponent.new worker: ScanPlexWorker do |c|
      c.with_body do
        ProgressBarComponent.new \
          model: Movie,
          completed: (completed / plex_movies.size.to_f * 100),
          status: :info,
          message: message || 'Scanning Plex...'
      end
    end
  end

  def search_for_movie(blob) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    options = { query: blob.parsed_dirname.title, year: blob.parsed_dirname.year }.compact
    dirname = TheMovieDb::Search::Movie.new(**options) if options[:query].present?

    options = { query: blob.parsed_filename.title, year: blob.parsed_filename.year }.compact
    filename = TheMovieDb::Search::Movie.new(**options) if options[:query].present?

    dirname&.results&.dig('results', 0, 'id') || filename&.results&.dig('results', 0, 'id')
  end

  def create_movie!(blob)
    the_movie_db_id = search_for_movie(blob)
    return if the_movie_db_id.nil?

    Movie.find_or_initialize_by(the_movie_db_id:).tap do |m|
      m.subscribe(TheMovieDb::MovieListener.new)
      m.save!
    end
  end

  def plex_movies
    @plex_movies ||= Ftp::VideoScannerService.call.movies
  end

  def completed
    @completed ||= 0
  end

  attr_writer :completed
end
