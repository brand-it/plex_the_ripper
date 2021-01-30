# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id               :integer          not null, primary key
#  backdrop_path    :string
#  episode_run_time :string
#  first_air_date   :date
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
FactoryBot.define do
  factory :video do
    title { Faker::Book.title }
    original_title { Faker::Book.title }

    trait :with_movie_db_id do
      the_movie_db_id { Faker::Number.number }
    end
  end
end
