# frozen_string_literal: true

# == Schema Information
#
# Table name: movies
#
#  id              :integer          not null, primary key
#  backdrop_path   :string
#  file_path       :string
#  original_title  :string
#  overview        :string
#  poster_path     :string
#  release_date    :date
#  title           :string
#  workflow_state  :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :integer
#  disk_title_id   :integer
#  the_movie_db_id :integer
#
# Indexes
#
#  index_movies_on_disk_id        (disk_id)
#  index_movies_on_disk_title_id  (disk_title_id)
#
class Movie < ApplicationRecord
  include DiskWorkflow
  include HasProgress
  include Wisper::Publisher

  with_options unless: :the_movie_db_id do
    validates :title, presence: true
    validates :original_title, presence: true
  end

  before_save { broadcast(:movie_saving, self) }
  after_commit { broadcast(:movie_saved, id) }

  def rip
    CreateMovieWorker.perform(movie: self, disk_title: disk_title)
  end
end
