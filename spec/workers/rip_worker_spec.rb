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

    context 'when happy path' do
      it('returns result object') { is_expected.to eq([stub_result]) }
    end

    context 'when a part is given' do
      let(:disk_titles) { [id: disk_title.id, part: 1] }

      it('returns result object') { is_expected.to eq([stub_result]) }
    end

    context 'when a part is given but it is a string value' do
      let(:disk_titles) { [id: disk_title.id, part: '1'] }

      it 'call CreateMkvService with params' do
        expect(perform).to eq([stub_result])
        expect(CreateMkvService).to have_received(:new).with(
          disk_title: disk_title,
          extra_type: nil,
          edition: nil,
          part: 1
        )
      end
    end

    context 'when a part is given but it is a string value but it is zero' do
      let(:disk_titles) { [id: disk_title.id, part: '0'] }

      it 'call CreateMkvService with params' do
        expect(perform).to eq([stub_result])
        expect(CreateMkvService).to have_received(:new).with(
          disk_title: disk_title,
          extra_type: nil,
          edition: nil,
          part: nil
        )
      end
    end

    context 'when a part is given but it is a blank value' do
      let(:disk_titles) { [id: disk_title.id, part: ''] }

      it 'call CreateMkvService with params' do
        expect(perform).to eq([stub_result])
        expect(CreateMkvService).to have_received(:new).with(
          disk_title: disk_title,
          extra_type: nil,
          edition: nil,
          part: nil
        )
      end
    end
  end
end
