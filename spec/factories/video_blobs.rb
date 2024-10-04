# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id                :integer          not null, primary key
#  byte_size         :bigint           not null
#  checksum          :text
#  content_type      :string           not null
#  edition           :string
#  extra_type        :integer          default("feature_films")
#  extra_type_number :integer
#  filename          :string           not null
#  key               :string           not null
#  metadata          :text
#  optimized         :boolean          default(FALSE), not null
#  uploadable        :boolean          default(FALSE), not null
#  uploaded_on       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  episode_id        :bigint
#  video_id          :integer
#
# Indexes
#
#  idx_on_extra_type_number_video_id_extra_type_1978193db6  (extra_type_number,video_id,extra_type) UNIQUE
#  index_video_blobs_on_key                                 (key) UNIQUE
#  index_video_blobs_on_key_and_service_name                (key) UNIQUE
#  index_video_blobs_on_video                               (video_id)
#
FactoryBot.define do
  factory :video_blob do
    video factory: %i[movie]
    filename { 'Back to the Future Part III.mkv' }
    content_type { 'video/x-matroska' }
    byte_size { 123_456_789 }

    after(:stub) do |blob, _context|
      blob.send(:set_defaults)
    end
  end
end
