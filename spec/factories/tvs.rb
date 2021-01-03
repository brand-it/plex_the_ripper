# frozen_string_literal: true

# == Schema Information
#
# Table name: tvs
#
#  id               :integer          not null, primary key
#  backdrop_path    :string
#  episode_run_time :string
#  first_air_date   :string
#  name             :string
#  original_name    :string
#  overview         :string
#  poster_path      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  the_movie_db_id  :integer
#
FactoryBot.define do
  factory :tv do
    name { Faker::Book.title }
    original_name { Faker::Book.title }
  end
end
