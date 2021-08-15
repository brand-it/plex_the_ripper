# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id           :integer          not null, primary key
#  byte_size    :bigint           not null
#  content_type :string           not null
#  filename     :string           not null
#  key          :string           not null
#  metadata     :text
#  optimized    :boolean          default(FALSE), not null
#  service_name :string           not null
#  video_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  video_id     :integer
#
# Indexes
#
#  index_video_blobs_on_key_and_service_name  (key,service_name) UNIQUE
#  index_video_blobs_on_video                 (video_type,video_id)
#
require 'rails_helper'

RSpec.describe VideoBlob, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
