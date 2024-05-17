# frozen_string_literal: true

class ContinueUploadWorker < ApplicationWorker
  def enqueue?
    pending_movies.present?
  end

  def perform
    pending_movies.each do |movie|
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
end
