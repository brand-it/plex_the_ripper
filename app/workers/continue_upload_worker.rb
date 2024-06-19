# frozen_string_literal: true

class ContinueUploadWorker < ApplicationWorker
  def enqueue?
    (pending_movies + pending_episodes).any?
  end

  def perform
    (pending_movies + pending_episodes).each do |movie|
      UploadWorker.perform_async(disk_title_id: movie.disk_title.id)
    end
  end

  def pending_movies
    @pending_movies ||= [].tap do |movies|
      Movie.find_each do |movie|
        next unless movie.tmp_plex_path_exists?

        movies << movie
      end
    end
  end

  def pending_episodes
    @pending_episodes ||= [].tap do |episodes|
      Episode.find_each do |episode|
        next unless episode.tmp_plex_path_exists?

        episodes << episode
      end
    end
  end
end
