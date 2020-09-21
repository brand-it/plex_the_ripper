# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  config_type :string           not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  config_id   :integer          not null
#
# Indexes
#
#  index_users_on_config_type_and_config_id  (config_type,config_id)
#
FactoryBot.define do
  factory :user do
    name { Faker::Internet.username }
    association :config, factory: :config_user
  end
end
