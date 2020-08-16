# frozen_string_literal: true

class Movie < ApplicationRecord
  include DiskWorkflow

  validates :title, presence: true
  validates :original_title, presence: true

  private

  def update_from_the_movie_db
    self.attributes = the_movie_db_movie.to_h
  end

  def the_movie_db_movie
    @the_movie_db_movie ||= TheMovieDb::Movie.new(movie_id: params[:the_movie_db_id]).results
  end
end
