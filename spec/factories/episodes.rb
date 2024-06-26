# frozen_string_literal: true

# == Schema Information
#
# Table name: episodes
#
#  id              :integer          not null, primary key
#  air_date        :date
#  episode_number  :integer
#  file_path       :string
#  name            :string
#  overview        :string
#  runtime         :integer
#  still_path      :string
#  workflow_state  :string
#  disk_title_id   :bigint
#  season_id       :bigint
#  the_movie_db_id :integer
#
# Indexes
#
#  index_episodes_on_disk_title_id  (disk_title_id)
#  index_episodes_on_season_id      (season_id)
#
FactoryBot.define do
  factory :episode do
    season
    the_movie_db_id { Faker::Number.number }
  end
end
