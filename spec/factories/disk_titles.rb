# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  angle           :integer
#  description     :string
#  duration        :integer
#  filename        :string           not null
#  name            :string
#  ripped_at       :datetime
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  episode_id      :integer
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#  video_blob_id   :integer
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_id)
#  index_disk_titles_on_video_blob_id    (video_blob_id)
#
FactoryBot.define do
  factory :disk_title do
    filename { 'title_mk1.mkv' } # don't rename required for spec/bin/makemkvcon_test
    title_id { Faker::Types.rb_integer }
    disk
    video
    episode

    trait(:with_movie) { video factory: %i[movie] }
  end
end
