# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadDiskWorker, type: :worker do
  subject(:worker) { described_class.new(job:) }

  let(:job) { build_stubbed(:job) }

  describe '#perform' do
    subject(:perform) { worker.perform }

    it { expect { perform }.not_to raise_error }

    it { expect { perform }.to change(Disk, :count).by(1) }
  end
end
