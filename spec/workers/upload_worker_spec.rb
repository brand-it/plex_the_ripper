# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadWorker, type: :worker do
  subject(:worker) { described_class.new(video_blob_id:, job:) }

  let(:disk_title) { create(:disk_title, video: movie, video_blob:) }
  let(:video_blob) { create(:video_blob, video: movie, uploadable: true) }
  let(:movie) { create(:movie) }
  let(:video_blob_id) { video_blob.id }
  let(:job) { create(:job) }
  let(:stub_ftp) { instance_double(Net::FTP) }

  before do
    create(:config_plex)
    allow(Net::FTP).to receive(:new).and_return(stub_ftp)
    allow(stub_ftp).to receive(:delete)
    allow(stub_ftp).to receive(:mkdir)
    allow(stub_ftp).to receive(:putbinaryfile)

    FileUtils.mkdir_p(video_blob.tmp_plex_path)
  end

  describe '#perform' do
    subject(:perform) { worker.perform }

    it { is_expected.to be_a(Ftp::UploadMkvService) }
  end
end
