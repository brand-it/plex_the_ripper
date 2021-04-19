# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  backdrop_path                :string
#  episode_distribution_runtime :string
#  episode_first_air_date       :date
#  movie_runtime                :integer
#  original_title               :string
#  overview                     :string
#  poster_path                  :string
#  release_date                 :date
#  synced_on                    :datetime
#  title                        :string
#  type                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Movie < Video
  before_save { broadcast(:movie_saving, self) }
  after_commit { broadcast(:movie_saved, id) }

  MOVIE_RUNNTIME_MARGIN = 10.minutes.to_i

  with_options unless: :the_movie_db_id do
    validates :title, presence: true
    validates :original_title, presence: true
  end

  def runtime_range
    (movie_runtime - MOVIE_RUNNTIME_MARGIN)..(movie_runtime + MOVIE_RUNNTIME_MARGIN)
  end

  def rip
    # CreateMovieWorker.perform(movie: self, disk_title: disk_titles)
  end

  def update_maxlength(max)
    return config.maxlength = (max + MOVIE_DURATION_MARGIN) if max.to_i > (config.minlength / 60)

    config.maxlength = nil
  end
end
