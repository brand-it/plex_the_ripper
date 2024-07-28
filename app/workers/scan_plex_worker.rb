# frozen_string_literal: true

class ScanPlexWorker < ApplicationWorker
  def perform
    broadcast_progress(ScanPlexProcessComponent.new)
    plex_videos.map do |blob|
      blob.video = find_or_create_video(blob)
      blob.episode = search_for_episode(blob, blob.video)
      blob.uploaded_on ||= Time.current
      blob.save!
      self.completed += 1
      job.metadata['completed'] = (completed / plex_videos.size.to_f * 100)
      next if next_update.future?

      job.save!
      broadcast_component(ScanPlexProcessComponent.new)
      @next_update = 1.second.from_now
    end
    job.update!(metadata: { 'completed' => 100 })
    broadcast_component(ScanPlexProcessComponent.new)
  end

  def completed
    @completed ||= 0
  end

  private

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

  def search_for_episode(blob, video)
    return unless video.is_a?(::Tv)

    season = video.seasons.find { _1.season_number == blob.parsed_season }
    return if season.nil?

    season.subscribe(TheMovieDb::EpisodesListener.new)
    season.save!
    season.episodes.find { _1.episode_number == blob.parsed_episode }
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

  def plex_videos
    @plex_videos ||= Ftp::VideoScannerService.call
  end

  def next_update
    @next_update ||= 1.second.from_now
  end

  attr_writer :completed
end
