# frozen_string_literal: true

# == Schema Information
#
# Table name: episodes
#
#  id              :integer          not null, primary key
#  air_date        :date
#  episode_number  :integer
#  file_path       :string
#  name            :string
#  overview        :string
#  runtime         :integer
#  still_path      :string
#  workflow_state  :string
#  season_id       :bigint
#  the_movie_db_id :integer
#
# Indexes
#
#  index_episodes_on_season_id  (season_id)
#
require 'rails_helper'

RSpec.describe Episode do
  describe 'associations' do
    it { is_expected.to belong_to(:season).optional(false) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:episode_number) }
  end

  describe 'scopes' do
    it { is_expected.to have_scope(:order_by_episode_number).order(:episode_number) }
  end

  describe '#tv' do
    subject(:tv) { build_stubbed(:episode).tv }

    it { is_expected.to be_a(Tv) }
  end

  describe '#plex_name' do
    subject(:plex_name) { episode.plex_name(part:, episode_last:) }

    let(:episode) { build_stubbed(:episode, season:) }
    let(:season) { build_stubbed(:season, tv:, season_number: 1) }
    let(:tv) { build_stubbed(:tv, name: 'The Violent Bear It Away') }
    let(:part) { nil }
    let(:episode_last) { nil }

    context 'when part is given' do
      let(:part) { 1 }

      it { is_expected.to eq 'The Violent Bear It Away - s01e01 - pt1' }
    end

    context 'when episode_last is given' do
      let(:episode_last) { build_stubbed(:episode, season:, episode_number: 3) }

      it { is_expected.to eq 'The Violent Bear It Away - s01e01-e03' }
    end

    context 'when episode_last is given & part' do
      let(:episode_last) { build_stubbed(:episode, season:, episode_number: 3) }
      let(:part) { 1 }

      it { is_expected.to eq 'The Violent Bear It Away - s01e01-e03 - pt1' }
    end
  end
end
