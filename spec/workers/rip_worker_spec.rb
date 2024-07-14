# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RipWorker, type: :worker do
  subject(:worker) { described_class.new(disk_id:, disk_title_ids:, job:) }

  let(:disk_title) { create(:disk_title, episode:) }
  let(:disk_title_ids) { [disk_title.id] }
  let(:disk) { disk_title.disk }
  let(:disk_id) { disk.id }
  let(:job) { create(:job) }
  let(:episode) { create(:episode) }

  describe '#perform' do
    subject(:perform) { worker.perform }

    let(:stub) { instance_double(CreateMkvService, :call) }

    before do
      allow(CreateMkvService).to receive(:new).and_return(stub)
      allow(stub).to receive(:subscribe)
      allow(stub).to receive(:call)
    end

    it { expect { perform }.not_to raise_error }
  end
end
