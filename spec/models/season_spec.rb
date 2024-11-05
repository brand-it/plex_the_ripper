# frozen_string_literal: true

# == Schema Information
#
# Table name: seasons
#
#  id              :integer          not null, primary key
#  air_date        :date
#  name            :string
#  overview        :string
#  poster_path     :string
#  season_number   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  the_movie_db_id :integer
#  tv_id           :bigint
#
# Indexes
#
#  index_seasons_on_tv_id  (tv_id)
#
require 'rails_helper'

RSpec.describe Season do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:season_number) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:episodes) }
    it { is_expected.to belong_to(:tv).optional(false) }
  end

  describe '#duration_stats' do
    subject(:duration_stats) { season.duration_stats }

    let(:episodes) { build_stubbed_list(:episode, 1, season:, ripped_disk_titles:) }
    let(:season) { build_stubbed(:season) }
    let(:ripped_disk_titles_durations) { ripped_disk_titles.map(&:duration)&.sort || [] }

    before do
      season.association(:episodes).target = episodes
      season.association(:episodes).loaded!
      season.association(:ripped_disk_titles).target = ripped_disk_titles
      season.association(:ripped_disk_titles).loaded!
    end

    context 'when durations are even' do
      let(:ripped_disk_titles) { build_stubbed_list(:disk_title, 3, :ripped, :with_duration) }

      it { is_expected.to be_a(StatsService::Info) }
    end

    context 'when durations are odd' do
      let(:ripped_disk_titles) { build_stubbed_list(:disk_title, 2, :ripped, :with_duration) }

      it { is_expected.to be_a(StatsService::Info) }
    end

    context 'when only one duration' do
      let(:ripped_disk_titles) { build_stubbed_list(:disk_title, 1, :ripped, :with_duration) }

      it { is_expected.to be_a(StatsService::Info) }
    end

    context 'when no durations' do
      let(:ripped_disk_titles) { build_stubbed_list(:disk_title, 2, :ripped) }

      it { is_expected.to be_a(StatsService::Info) }
    end

    context 'when no ripped_disk_titles' do
      let(:ripped_disk_titles) { [] }

      it { is_expected.to be_a(StatsService::Info) }
    end
  end
end
