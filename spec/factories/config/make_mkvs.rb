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
  factory :config_make_mkv, class: 'Config::MakeMkv' do
    settings { { makemkvcon_path: Rails.root.join('spec/bin/makemkvcon_test') } }
  end
end
