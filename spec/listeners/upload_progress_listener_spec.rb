# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadProgressListener do
  subject(:listener) { described_class.new(**args) }

  describe '#upload_progress' do
    subject(:upload_progress) { listener.upload_progress(total_uploaded: 10) }

    let(:video_blob) { build_stubbed(:video_blob) }
    let(:job) { build(:job) }
    let(:args) do
      {
        video_blob:,
        file_size: 12,
        job:
      }
    end

    it 'changes the completed size based on the chunk size' do
      upload_progress

      expect(listener.job.metadata).to eq('completed' => 10)
    end
  end
end
