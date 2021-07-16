# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  settings   :text
#  type       :string           default("Config"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :config_the_movie_db, class: 'Config::TheMovieDb' do
    settings { { api_key: ENV.fetch('MOVIE_DB_TEST_API_KEY', 12_345) } }
  end
end
