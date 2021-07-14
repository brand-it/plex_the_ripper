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
  factory :config_plex, class: 'Config::Plex' do
    settings_movie_path { '/it/is/not/real' }
    settings_tv_path { '/there/is/no/video/path' }
  end
end
