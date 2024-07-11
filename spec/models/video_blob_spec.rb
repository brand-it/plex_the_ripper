# frozen_string_literal: true

# == Schema Information
#
# Table name: video_blobs
#
#  id           :integer          not null, primary key
#  byte_size    :bigint           not null
#  checksum     :text
#  content_type :string           not null
#  filename     :string           not null
#  key          :string           not null
#  metadata     :text
#  optimized    :boolean          default(FALSE), not null
#  service_name :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  episode_id   :bigint
#  video_id     :integer
#
# Indexes
#
#  index_video_blobs_on_key_and_service_name  (key,service_name) UNIQUE
#  index_video_blobs_on_video                 (video_id)
#
require 'rails_helper'

RSpec.describe VideoBlob do
  let(:video_blob) { build(:video_blog) }

  describe 'associations' do
    it { is_expected.to belong_to(:video).optional(true) }
    it { is_expected.to belong_to(:episode).optional(true) }
  end

  describe 'scopes' do
    it { is_expected.to have_scope(:optimized).where(optimized: true) }
    it { is_expected.to have_scope(:checksum).where.not(checksum: nil) }
    it { is_expected.to have_scope(:missing_checksum).where(checksum: nil) }
  end

  describe '#tv_show?' do
    subject(:tv_show?) { video_blob.tv_show? }

    before do
      allow(Config::Plex).to receive(:newest).and_return(config_plex)
    end

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
    subject(:tv_show?) { video_blob.movie? }

    before do
      allow(Config::Plex).to receive(:newest).and_return(config_plex)
    end

    context 'when path does not start with movie path' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '/Media/Movie') }

      let(:video_blob) { build_stubbed(:video_blob, key: '/Movie') }

      it { is_expected.to be(false) }
    end

    context 'when path does start with movie path' do
      let(:config_plex) { build_stubbed(:config_plex, settings_movie_path: '/Media/Movie') }
      let(:video_blob) { build_stubbed(:video_blob, key: '/Media/Movie') }

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
end
