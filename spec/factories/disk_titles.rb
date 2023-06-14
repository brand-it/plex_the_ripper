# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  duration        :integer
#  name            :string           not null
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#
FactoryBot.define do
  factory :disk_title do
    name { Faker::App.name }
    title_id { Faker::Types.rb_integer }
    disk

    trait(:with_movie) { movie factory: %i[movie] }
  end
end
