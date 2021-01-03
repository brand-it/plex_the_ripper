# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id         :integer          not null, primary key
#  duration   :integer
#  name       :string           not null
#  size       :float
#  video_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  disk_id    :bigint
#  title_id   :integer          not null
#  video_id   :bigint
#
# Indexes
#
#  index_disk_titles_on_disk_id                  (disk_id)
#  index_disk_titles_on_video_type_and_video_id  (video_type,video_id)
#
require 'rails_helper'

RSpec.describe DiskTitle, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:disk) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:disk) }
  end
end
