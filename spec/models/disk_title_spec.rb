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
#  segment_map     :string
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  episode_id      :integer
#  episode_last_id :integer
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#  video_blob_id   :integer
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_episode_last_id  (episode_last_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_id)
#  index_disk_titles_on_video_blob_id    (video_blob_id)
#
require 'rails_helper'

RSpec.describe DiskTitle do
  describe 'associations' do
    it { is_expected.to belong_to(:disk).optional(true) }
    it { is_expected.to belong_to(:episode).optional(true) }
    it { is_expected.to belong_to(:episode_last).optional(true) }
    it { is_expected.to belong_to(:video).optional(true) }
    it { is_expected.to belong_to(:video_blob).optional(true) }
  end

  describe 'scopes' do
    it { is_expected.to have_scope(:not_ripped).where(ripped_at: nil) }
    it { is_expected.to have_scope(:ripped).where.not(ripped_at: nil) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:filename) }
  end

  describe '#to_label' do
    let(:disk_title) { create(:disk_title, title_id: 1, name: 'Sample Title', duration: 3600) }

    it 'returns the correct label' do
      expect(disk_title.to_label).to eq('#1 title_mk1.mkv 1 hr')
    end
  end

  describe 'before_save' do
    context 'when the episode_last is not set but episode is' do
      let(:disk_title) { create(:disk_title, episode:) }
      let(:episode) { create(:episode) }

      it { expect { disk_title }.to change { described_class.first&.episode_last_id }.from(nil).to(episode.id) }
    end
  end

  describe '#episode_numbers' do
    subject(:episode_numbers) { disk_title.episode_numbers }

    context 'when no episode is present' do
      let(:disk_title) { build_stubbed(:disk_title, episode: nil) }

      it { is_expected.to be_nil }
    end

    context 'when episode is present' do
      let(:disk_title) { build_stubbed(:disk_title, episode:) }
      let(:episode) { build_stubbed(:episode, episode_number: 1) }

      it { is_expected.to eq(1..1) }
    end

    context 'when episode is present & last_episode' do
      let(:disk_title) { build_stubbed(:disk_title, episode:, episode_last:) }
      let(:episode) { build_stubbed(:episode, episode_number: 1) }
      let(:episode_last) { build_stubbed(:episode, episode_number: 10) }

      it { is_expected.to eq(1..10) }
    end
  end
end
