# frozen_string_literal: true

# == Schema Information
#
# Table name: progresses
#
#  id                :integer          not null, primary key
#  attempts          :integer          default(0), not null
#  completed_at      :datetime
#  descriptive       :integer          default("download_ftp"), not null
#  failed_at         :datetime
#  key               :string
#  message           :text
#  percentage        :float
#  progressable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  progressable_id   :integer
#
# Indexes
#
#  index_progresses_on_progressable_type_and_progressable_id  (progressable_type,progressable_id)
#
require 'rails_helper'

RSpec.describe Progress do
  describe 'associations' do
    it { is_expected.to belong_to(:progressable).optional(false) }
  end

  # V
  describe 'validations' do
    it { is_expected.to validate_presence_of(:descriptive) }
  end
end
