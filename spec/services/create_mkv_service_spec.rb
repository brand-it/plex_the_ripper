# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateMkvService do
  let(:service) { described_class.new(disk_title: disk_title, progress_listener: progress_listener) }
  let(:disk_title) { build_stubbed(:disk_title) }
  let(:progress_listener) { instance_double('UploadProgressListener', call: nil) }

  before { create :config_make_mkv }

  describe '#call' do
    subject(:call) { service.call }

    context 'when the disk title is valid' do
      let(:disk_title) { build_stubbed(:disk_title, :with_movie) }
      let(:progress_listener) { instance_double('UploadProgressListener', call: nil) }

      before { allow(service).to receive(:cmd).and_return('ls /not-a-real-folder') }

      it 'calls progress listener' do
        call
        expect(progress_listener).to have_received(:call).with(OpenStruct.new(type: 'ls', line: [0]))
      end

      it 'responds with a result object' do
        expect(call).to eq(described_class::Result.new(disk_title.video.tmp_plex_path, false))
      end
    end
  end
end
