# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id         :integer          not null, primary key
#  duration   :integer
#  message    :text
#  name       :string           not null
#  size       :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  disk_id    :integer
#  title_id   :integer          not null
#
# Indexes
#
#  index_disk_titles_on_disk_id  (disk_id)
#
FactoryBot.define do
  factory :disk_title do
    name { Faker::App.name }
    title_id { Faker::Types.rb_integer }
    disk
  end
end
