# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id               :integer          not null, primary key
#  backdrop_path    :string
#  episode_run_time :string
#  first_air_date   :string
#  original_title   :string
#  overview         :string
#  poster_path      :string
#  release_date     :date
#  synced_on        :datetime
#  title            :string
#  type             :string
#  workflow_state   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  the_movie_db_id  :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Movie < Video
  include DiskWorkflow
  include HasProgress
  include Wisper::Publisher
  include AsVideo

  before_save { broadcast(:movie_saving, self) }
  after_commit { broadcast(:movie_saved, id) }

  with_options unless: :the_movie_db_id do
    validates :title, presence: true
    validates :original_title, presence: true
  end

  def rip
    # CreateMovieWorker.perform(movie: self, disk_title: disk_titles)
  end
end
