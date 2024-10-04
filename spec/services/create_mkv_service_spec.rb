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
  end
end
