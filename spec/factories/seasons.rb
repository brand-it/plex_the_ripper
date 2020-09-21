# frozen_string_literal: true

# == Schema Information
#
# Table name: seasons
#
#  id              :integer          not null, primary key
#  air_date        :date
#  name            :string
#  overview        :string
#  poster_path     :string
#  season_number   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  the_movie_db_id :integer
#  tv_id           :integer
#
# Indexes
#
#  index_seasons_on_tv_id  (tv_id)
#
FactoryBot.define do
  factory :season do
    season_number { 1 }
    tv
  end
end
