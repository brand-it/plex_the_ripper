# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadProgressListener do
  subject(:listener) { described_class.new(**args) }

  describe '#update_progress' do
    subject(:update_progress) { listener.update_progress(chunk_size: 10) }

    let(:disk_title) { build_stubbed(:disk_title) }
    let(:args) do
      {
        disk_title:,
        file_size: 12
      }
    end

    it { expect { update_progress }.not_to raise_error }

    it 'changes the completed size based on the chunk size' do
      update_progress

      expect(listener.completed).to eq 10
    end
  end
end
