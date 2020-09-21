# frozen_string_literal: true

# == Schema Information
#
# Table name: disks
#
#  id             :integer          not null, primary key
#  disk_name      :string
#  name           :string
#  workflow_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'rails_helper'

RSpec.describe Disk, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:episodes) }
    it { is_expected.to have_many(:disk_titles) }
  end
end
