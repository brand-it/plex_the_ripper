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
#  popularity                   :float
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
FactoryBot.define do
  factory :video do
    title { Faker::Book.title }
    original_title { Faker::Book.title }

    trait :with_movie_db_id do
      the_movie_db_id { Faker::Number.number }
    end
  end
end
