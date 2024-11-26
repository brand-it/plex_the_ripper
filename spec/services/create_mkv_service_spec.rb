# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateMkvService do
  let(:service) { described_class.new(disk_title:) }

  before { create(:config_make_mkv) }

  describe '#call' do
    subject(:call) { service.call }

    context 'when the disk title is valid' do
      let(:disk_title) { create(:disk_title, video: movie) }
      let(:movie) { create(:movie) }

      before { allow(service).to receive(:cmd).and_return('ls /not-a-real-folder') }

      it 'responds with a result object' do
        expect(call).to be_a(described_class::Result)
      end
    end

    context 'when a video blob already exists' do
      let(:service) { described_class.new(disk_title:, edition: '') }
      let(:disk_title) { create(:disk_title, video: movie, episode: nil) }
      let(:movie) { create(:movie) }

      before do
        allow(service).to receive(:cmd).and_return('ls /not-a-real-folder')
        create(:video_blob, video: movie)
      end

      it 'responds with a result object' do
        expect(call).to be_a(described_class::Result)
      end
    end

    context 'when part is passed in' do
      let(:service) { described_class.new(disk_title:, part: 1) }
      let(:disk_title) { create(:disk_title, video: tv, episode:) }
      let(:tv) { create(:tv) }
      let(:episode) { create(:episode) }

      before do
        allow(service).to receive(:cmd).and_return('ls /not-a-real-folder')
      end

      it 'build a video blob with all the attributes on the disk title' do
        expect { call }.to change(VideoBlob, :count).by(1)
        expect(VideoBlob.first.part).to eq(1)
        expect(VideoBlob.includes(:episode_last).first.episode_last).to eq(episode)
      end
    end

    context 'when disk titles has a range of episodes' do
      let(:service) { described_class.new(disk_title:, part: 1) }
      let(:disk_title) { create(:disk_title, video: tv, episode:, episode_last:) }
      let(:tv) { create(:tv) }
      let(:episode) { create(:episode) }
      let(:episode_last) { create(:episode) }

      before do
        allow(service).to receive(:cmd).and_return('ls /not-a-real-folder')
      end

      it 'build a video blob with all the attributes on the disk title' do
        expect { call }.to change(VideoBlob, :count).by(1)
        expect(VideoBlob.first.part).to eq(1)
        expect(VideoBlob.includes(:episode_last).first.episode_last).to eq(episode_last)
      end
    end
  end
end
