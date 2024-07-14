# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  duration        :integer
#  name            :string           not null
#  ripped_at       :datetime
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  episode_id      :integer
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#  video_blob_id   :integer
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_id)
#  index_disk_titles_on_video_blob_id    (video_blob_id)
#
require 'rails_helper'

RSpec.describe DiskTitle do
  describe 'associations' do
    it { is_expected.to belong_to(:disk).optional(true) }
    it { is_expected.to belong_to(:episode).optional(true) }
    it { is_expected.to belong_to(:video).optional(true) }
    it { is_expected.to belong_to(:video_blob).optional(true) }
  end

  describe 'scopes' do
    it { is_expected.to have_scope(:not_ripped).where(ripped_at: nil) }
    it { is_expected.to have_scope(:ripped).where.not(ripped_at: nil) }
  end

  describe '#to_label' do
    let(:disk_title) { create(:disk_title, title_id: 1, name: 'Sample Title', duration: 3600) }

    it 'returns the correct label' do
      expect(disk_title.to_label).to eq('#1 Sample Title 1 hour')
    end
  end

  describe '#tmp_plex_path' do
    subject(:tmp_plex_path) { disk_title.tmp_plex_path }

    context 'when video is a TV' do
      let(:episode) { build_stubbed(:episode) }
      let(:disk_title) { build_stubbed(:disk_title, video: episode.tv, episode:, video_blob:) }
      let(:video_blob) { build_stubbed(:video_blob, video: episode.tv, episode:) }

      it 'returns the temporary Plex path for the episode' do
        expect(tmp_plex_path.to_s).to end_with("#{episode.plex_name}.mkv")
      end
    end

    context 'when video is a Movie' do
      let(:movie) { build_stubbed(:movie) }
      let(:disk_title) { build_stubbed(:disk_title, video: movie, video_blob:) }
      let(:video_blob) { build_stubbed(:video_blob, video: movie) }

      it 'returns the temporary Plex path for the movie' do
        expect(tmp_plex_path.to_s).to end_with("#{movie.plex_name}.mkv")
      end
    end
  end

  describe '#plex_path' do
    subject(:plex_path) { disk_title.plex_path }

    before { create(:config_plex) }

    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:, video_blob:) }
      let(:video_blob) { create(:video_blob, video: episode.tv, episode:) }

      it 'returns the Plex path for the episode' do
        expect(plex_path.to_s).to end_with("Season 01/#{episode.plex_name}.mkv")
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie, video_blob:) }
      let(:video_blob) { create(:video_blob, video: movie) }

      it 'returns the Plex path for the movie' do
        expect(plex_path.to_s).to end_with("#{movie.plex_name}/#{movie.plex_name}.mkv")
      end
    end
  end

  describe '#tmp_plex_dir' do
    subject(:tmp_plex_dir) { disk_title.tmp_plex_dir }

    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:, video_blob:) }
      let(:video_blob) { create(:video_blob, video: episode.tv, episode:) }

      it 'returns the temporary Plex directory for the episode' do
        expect(tmp_plex_dir.to_s).to end_with("#{episode.tv.plex_name}/Season 01")
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie, video_blob:) }
      let(:video_blob) { create(:video_blob, video: movie) }

      it 'returns the temporary Plex directory for the movie' do
        expect(tmp_plex_dir.to_s).to end_with(movie.plex_name)
      end
    end
  end

  describe '#tmp_plex_path_exists?' do
    subject(:tmp_plex_path_exists?) { disk_title.tmp_plex_path_exists? }

    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:, video_blob:) }
      let(:video_blob) { create(:video_blob, video: episode.tv, episode:) }

      it 'returns whether the temporary Plex path exists for the episode' do
        expect(tmp_plex_path_exists?).to be(false)
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie, video_blob:) }
      let(:video_blob) { create(:video_blob, video: movie) }

      it 'returns whether the temporary Plex path exists for the movie' do
        expect(tmp_plex_path_exists?).to be(false)
      end
    end
  end
end
