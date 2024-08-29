# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScanPlexWorker, type: :worker do
  describe '#perform' do
    subject(:perform) { described_class.new(job:).perform }

    let(:job) { create(:job, metadata: {}) }
    let(:video_blobs) { build_list(:video_blob, 3) }
    let(:video) { create(:video) }

    before { allow(Ftp::VideoScannerService).to receive(:call).and_return(video_blobs) }

    it('returns a job') { is_expected.to eq(job) }
  end
end
