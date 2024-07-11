# frozen_string_literal: true

# == Schema Information
#
# Table name: disks
#
#  id             :integer          not null, primary key
#  disk_name      :string
#  ejected        :boolean          default(TRUE), not null
#  loading        :boolean          default(FALSE), not null
#  name           :string
#  workflow_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  episode_id     :integer
#  video_id       :integer
#
# Indexes
#
#  index_disks_on_episode_id  (episode_id)
#  index_disks_on_video       (video_id)
#
require 'rails_helper'

RSpec.describe Disk do
  describe 'associations' do
    it { is_expected.to have_many(:disk_titles) }
    it { is_expected.to have_many(:not_ripped_disk_titles).dependent(false).class_name('DiskTitle') }
    it { is_expected.to belong_to(:video).optional(true) }
    it { is_expected.to belong_to(:episode).optional(true) }
  end

  describe 'scopes' do
    it { is_expected.to have_scope(:not_ejected).where(ejected: false) }
    it { is_expected.to have_scope(:ejected).where(ejected: true) }
    it { is_expected.to have_scope(:not_loading).where(loading: false) }
    it { is_expected.to have_scope(:loading).where(loading: true) }
  end
end
