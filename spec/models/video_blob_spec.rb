# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id           :integer          not null, primary key
#  byte_size    :bigint           not null
#  checksum     :text
#  content_type :string           not null
#  filename     :string           not null
#  key          :string           not null
#  metadata     :text
#  optimized    :boolean          default(FALSE), not null
#  service_name :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  episode_id   :bigint
#  video_id     :integer
#
# Indexes
#
#  index_video_blobs_on_key_and_service_name  (key,service_name) UNIQUE
#  index_video_blobs_on_video                 (video_id)
#
require 'rails_helper'

RSpec.describe VideoBlob do
  describe 'associations' do
    it { is_expected.to have_many(:progresses).dependent(:destroy) }
    it { is_expected.to belong_to(:video).optional(true) }
  end
end
