# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  auto_start                   :boolean          default(FALSE), not null
#  backdrop_path                :string
#  episode_distribution_runtime :string
#  episode_first_air_date       :date
#  movie_runtime                :integer
#  original_title               :string
#  overview                     :string
#  popularity                   :float
#  poster_path                  :string
#  rating                       :integer          default("N/A"), not null
#  release_date                 :date
#  title                        :string
#  type                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Video do
  describe 'associations' do
    it { is_expected.to have_many(:disk_titles).dependent(:nullify) }
    it { is_expected.to have_many(:video_blobs).dependent(:nullify) }
    it { is_expected.to have_many(:optimized_video_blobs).dependent(:destroy) }
  end

  describe '#duration_stats' do
    subject(:duration_stats) { tv.duration_stats }

    let(:tv) { build_stubbed(:tv) }
    let(:ripped_disk_titles_durations) { ripped_disk_titles.map(&:duration)&.sort || [] }

    before do
      tv.association(:ripped_disk_titles).target = ripped_disk_titles
      tv.association(:ripped_disk_titles).loaded!
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
