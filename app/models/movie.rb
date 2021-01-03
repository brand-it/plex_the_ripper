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
#  the_movie_db_id :integer
#
class Movie < ApplicationRecord
  include DiskWorkflow
  include HasProgress
  include Wisper::Publisher
  include AsVideo

  before_save { broadcast(:movie_saving, self) }
  after_commit { broadcast(:movie_saved, id) }


  def rip
    # CreateMovieWorker.perform(movie: self, disk_title: disk_titles)
  end
end
