# frozen_string_literal: true

# == Schema Information
#
# Table name: mkv_progresses
#
#  id                :integer          not null, primary key
#  completed_at      :datetime
#  failed_at         :datetime
#  message           :text
#  name              :string
#  percentage        :float
#  progressable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  disk_id           :bigint
#  disk_title_id     :bigint
#  progressable_id   :bigint
#
# Indexes
#
#  index_mkv_progresses_on_disk_id                                (disk_id)
#  index_mkv_progresses_on_disk_title_id                          (disk_title_id)
#  index_mkv_progresses_on_progressable_type_and_progressable_id  (progressable_type,progressable_id)
#
require 'rails_helper'

RSpec.describe MkvProgress, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:disk_title) }
    it { is_expected.to belong_to(:video) }
  end
end
