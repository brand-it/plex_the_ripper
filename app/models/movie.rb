# frozen_string_literal: true

class Movie < ApplicationRecord
  include DiskWorkflow
  include HasProgress
  include Wisper::Publisher

  with_options unless: :the_movie_db_id do
    validates :title, presence: true
    validates :original_title, presence: true
  end

  before_save { broadcast(:movie_saving, self) }
  after_commit { broadcast(:movie_saved, id, async: true) }

  def rip
    CreateMovieJob.perform
  end
end
