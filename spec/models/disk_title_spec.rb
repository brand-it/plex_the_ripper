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
#  video_id        :integer
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_episode_id       (episode_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#  index_disk_titles_on_video            (video_id)
#
require 'rails_helper'

RSpec.describe DiskTitle do
  describe 'associations' do
    it { is_expected.to belong_to(:disk).optional(false) }
    it { is_expected.to belong_to(:episode).optional(true) }
    it { is_expected.to belong_to(:video).optional(true) }
  end

  describe '#to_label' do
    let(:disk_title) { create(:disk_title, title_id: 1, name: 'Sample Title', duration: 3600) }

    it 'returns the correct label' do
      expect(disk_title.to_label).to eq('#1 Sample Title 1 hour')
    end
  end

  describe '#tmp_plex_path' do
    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:) }

      it 'returns the temporary Plex path for the episode' do
        expect(disk_title.tmp_plex_path).to eq(episode.tmp_plex_path)
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie) }

      it 'returns the temporary Plex path for the movie' do
        expect(disk_title.tmp_plex_path).to eq(movie.tmp_plex_path)
      end
    end
  end

  describe '#plex_path' do
    before { create(:config_plex) }

    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:) }

      it 'returns the Plex path for the episode' do
        expect(disk_title.plex_path).to eq(episode.plex_path)
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie) }

      it 'returns the Plex path for the movie' do
        expect(disk_title.plex_path).to eq(movie.plex_path)
      end
    end
  end

  describe '#plex_name' do
    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:) }

      it 'returns the MKV file name for the episode' do
        expect(disk_title.plex_name).to eq(episode.plex_name)
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie) }

      it 'returns the MKV file name for the movie' do
        expect(disk_title.plex_name).to eq(movie.plex_name)
      end
    end
  end

  describe '#tmp_plex_dir' do
    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:) }

      it 'returns the temporary Plex directory for the episode' do
        expect(disk_title.tmp_plex_dir).to eq(episode.tmp_plex_dir)
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie) }

      it 'returns the temporary Plex directory for the movie' do
        expect(disk_title.tmp_plex_dir).to eq(movie.tmp_plex_dir)
      end
    end
  end

  describe '#tmp_plex_path_exists?' do
    context 'when video is a TV' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:) }

      it 'returns whether the temporary Plex path exists for the episode' do
        expect(disk_title.tmp_plex_path_exists?).to eq(episode.tmp_plex_path_exists?)
      end
    end

    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie) }

      it 'returns whether the temporary Plex path exists for the movie' do
        expect(disk_title.tmp_plex_path_exists?).to eq(movie.tmp_plex_path_exists?)
      end
    end
  end

  describe '#require_movie_or_episode!' do
    context 'when video is a Movie' do
      let(:movie) { create(:movie) }
      let(:disk_title) { create(:disk_title, video: movie) }

      it 'does not raise an error' do
        expect { disk_title.require_movie_or_episode! }.not_to raise_error
      end
    end

    context 'when video is a TV without episode' do
      let(:tv) { create(:tv) }
      let(:disk_title) { create(:disk_title, video: tv, episode: nil) }

      it 'raises an error' do
        expect { disk_title.require_movie_or_episode! }.to raise_error('requires episode or movie to rip')
      end
    end

    context 'when video is a TV with episode' do
      let(:episode) { create(:episode) }
      let(:disk_title) { create(:disk_title, video: episode.tv, episode:) }

      it 'does not raise an error' do
        expect { disk_title.require_movie_or_episode! }.not_to raise_error
      end
    end
  end
end
