# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RipWorker, type: :worker do
  subject(:worker) { described_class.new(disk_id:, disk_titles:, job:) }

  let(:disk_title) { create(:disk_title, episode:) }
  let(:disk_titles) { [id: disk_title.id] }
  let(:disk) { disk_title.disk }
  let(:disk_id) { disk.id }
  let(:job) { create(:job) }
  let(:episode) { create(:episode) }

  describe '#perform' do
    subject(:perform) { worker.perform }

    let(:stub) { instance_double(CreateMkvService, :call, disk_title:) }
    let(:stub_result) { instance_double(CreateMkvService::Result, success?: true) }

    before do
      allow(CreateMkvService).to receive(:new).and_return(stub)
      allow(stub).to receive(:subscribe)
      allow(stub).to receive(:call).and_return(stub_result)
    end

    it { is_expected.to eq([stub_result]) }
  end
end
