# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id                :integer          not null, primary key
#  byte_size         :bigint           not null
#  checksum          :text
#  content_type      :string           not null
#  extra_type        :integer          default("feature_films")
#  extra_type_number :integer          not null
#  filename          :string           not null
#  key               :string           not null
#  metadata          :text
#  optimized         :boolean          default(FALSE), not null
#  uploadable        :boolean          default(FALSE), not null
#  uploaded_on       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  episode_id        :bigint
#  video_id          :integer
#
# Indexes
#
#  idx_on_extra_type_number_video_id_extra_type_1978193db6  (extra_type_number,video_id,extra_type) UNIQUE
#  index_video_blobs_on_key                                 (key) UNIQUE
#  index_video_blobs_on_key_and_service_name                (key) UNIQUE
#  index_video_blobs_on_video                               (video_id)
#
require 'rails_helper'

RSpec.describe VideoBlob do
  subject(:video_blob) { build(:video_blob, extra_type_number: 1) }

  describe 'associations' do
    it { is_expected.to belong_to(:video) }
    it { is_expected.to belong_to(:episode).optional(true) }
    it { is_expected.to have_many(:disk_titles).dependent(:nullify) }
  end

  describe 'scopes', :freeze do
    it { is_expected.to have_scope(:checksum).where.not(checksum: nil) }
    it { is_expected.to have_scope(:missing_checksum).where(checksum: nil) }
    it { is_expected.to have_scope(:optimized).where(optimized: true) }
    it { is_expected.to have_scope(:uploadable).where(uploadable: true) }

    it {
      expect(subject).to have_scope(:uploaded_recently).where(described_class.arel_table[:uploaded_on].gteq(10.minutes.ago))
    }
  end

  describe 'extra_types' do
    subject(:extra_type) { described_class.extra_types }

    it 'defines a list of types' do
      expect(extra_type).to eq(
        {
          'feature_films' => 0,
          'behind_the_scenes' => 1,
          'deleted_scenes' => 2,
          'featurettes' => 3,
          'interviews' => 4,
          'scenes' => 5,
          'shorts' => 6,
          'trailers' => 7,
          'other' => 8
        }
      )
    end
  end

  describe '#extra_type_directory' do
    subject(:extra_type_directory) { video_blob.send(:extra_type_directory) }

    let(:video_blob) { build_stubbed(:video_blob, extra_type: :behind_the_scenes) }

    it { is_expected.to eq 'Behind The Scenes' }
  end

  describe '#plex_path' do
    subject(:plex_path) { video_blob.plex_path }

    before do
      config_plex = build_stubbed(:config_plex)
      allow(Config::Plex).to receive(:newest).and_return(config_plex)
    end

    context 'when feature_films extra type' do
      let(:video_blob) { build_stubbed(:video_blob, extra_type: :feature_films, video: movie) }
      let(:movie) { build_stubbed(:movie) }
      let(:expected_path) do
        plex_name = video_blob.send(:plex_name)
        "#{Config::Plex.newest.settings_movie_path}/#{plex_name}/#{plex_name}.mkv"
      end

      it { is_expected.to eq Pathname.new(expected_path) }
    end

    context 'when not feature_films extra type' do
      let(:video_blob) { build_stubbed(:video_blob, extra_type: :behind_the_scenes, video: movie) }
      let(:movie) { build_stubbed(:movie) }
      let(:expected_path) do
        "#{Config::Plex.newest.settings_movie_path}/#{movie.plex_name}/Behind The Scenes/Behind The Scenes #1.mkv"
      end

      it { is_expected.to eq Pathname.new(expected_path) }
    end

    context 'when not feature_films extra type & tv show' do
      let(:video_blob) { build_stubbed(:video_blob, extra_type: :behind_the_scenes, video: tv) }
      let(:tv) { build_stubbed(:tv) }
      let(:expected_path) do
        "#{Config::Plex.newest.settings_tv_path}/#{tv.plex_name}/Behind The Scenes/Behind The Scenes #1.mkv"
      end

      it { is_expected.to eq Pathname.new(expected_path) }
    end
  end

  describe '#set_extra_type_number' do
    context 'when using movies types' do
      let!(:video_blob_a) { create(:video_blob, video: movie, extra_type: :feature_films) }
      let!(:video_blob_b) { create(:video_blob, video: movie, extra_type: :feature_films) }
      let(:movie) { create(:movie) }

      it { expect(video_blob_a.extra_type_number).to eq 1 }
      it { expect(video_blob_b.extra_type_number).to eq 2 }
    end
  end

  describe '#tv_show?' do
    subject(:tv_show?) { video_blob.tv_show? }

    before { allow(Config::Plex).to receive(:newest).and_return(config_plex) }

    context 'when path does not start with tv show path' do
      let(:config_plex) { build_stubbed(:config_plex, settings_tv_path: '/Media/Tv Show') }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Tv Show') }

      it { is_expected.to be(false) }
    end

    context 'when path does start with tv show path' do
      let(:config_plex) { build_stubbed(:config_plex, settings_tv_path: '/Media/Tv Show') }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Media/Tv Show') }

      it { is_expected.to be(true) }
    end

    context 'when config it missing' do
      let(:config_plex) { nil }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Media/Movie') }

      it { is_expected.to be(false) }
    end

    context 'when config path is blank' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '') }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Media/Movie') }

      it { is_expected.to be(false) }
    end
  end

  describe '#movie?' do
    subject(:movie?) { video_blob.movie? }

    before do
      allow(Config::Plex).to receive(:newest).and_return(config_plex)
    end

    context 'when path does not start with movie path' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '/Media/Movie') }

      let(:video_blob) { build_stubbed(:video_blob, key: '/Movie', video: nil) }

      it { is_expected.to be(false) }
    end

    context 'when path does start with movie path' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '/Media/Movie') }
      let(:video_blob) { build_stubbed(:video_blob, video: nil, key: '/Media/Movie') }

      it { is_expected.to be(true) }
    end

    context 'when config it missing' do
      let(:config_plex) { nil }
      let(:video_blob) { build_stubbed(:video_blob, video: nil, key: '/Media/Movie') }

      it { is_expected.to be(false) }
    end

    context 'when config path is blank' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '') }
      let(:video_blob) { build_stubbed(:video_blob, video: nil, key: '/Media/Movie') }

      it { is_expected.to be(false) }
    end

    context 'when the video is tv' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '') }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Movie', video:) }
      let(:video) { build_stubbed(:tv) }

      it { is_expected.to be(false) }
    end

    context 'when the video is movie' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '') }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Movie', video:) }
      let(:video) { build_stubbed(:movie) }

      it { is_expected.to be(true) }
    end
  end
end
