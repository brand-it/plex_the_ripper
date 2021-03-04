# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  backdrop_path                :string
#  episode_distribution_runtime :string
#  episode_first_air_date       :date
#  movie_runtime                :string
#  original_title               :string
#  overview                     :string
#  poster_path                  :string
#  release_date                 :date
#  synced_on                    :datetime
#  title                        :string
#  type                         :string
#  workflow_state               :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Video < ApplicationRecord
  include DiskWorkflow
  include HasProgress
  include Wisper::Publisher
  class << self
    def find_video(id)
      id.nil? ? find(id) : (find_by(the_movie_db_id: id) || find(id))
    end
  end

  def release_or_air_date
    release_date || episode_first_air_date
  end
end
