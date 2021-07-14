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
#  disk_title_id                :bigint
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_disk_title_id             (disk_title_id)
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Video < ApplicationRecord
  include Wisper::Publisher

  belongs_to :disk_title, optional: true

  class << self
    def find_video(id)
      id.nil? ? find(id) : (find_by(the_movie_db_id: id) || find(id))
    end
  end

  def credits
    @credits ||= "TheMovieDb::#{type}::Credits".constantize.new(the_movie_db_id).results
  end

  def the_movie_db_details
    @the_movie_db_details ||= "TheMovieDb::#{type}".constantize.new(the_movie_db_id).results
  end

  def release_or_air_date
    release_date || episode_first_air_date
  end
end
