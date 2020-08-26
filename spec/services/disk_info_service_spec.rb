# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiskInfoService do
  include_context 'mkv_stubbs'
  before do
    allow(new_service).to receive(:info).and_return(title_info_object)
    allow(list_drives_service).to receive(:info).and_return(drive_info_object)
  end

  let(:list_drives_service) { ListDrivesService.new(config_make_mkv: config_make_mkv) }

  let(:config_make_mkv) { create :config_make_mkv }
  let(:new_service) do
    described_class.new(config_make_mkv: config_make_mkv, drive: list_drives_service.call)
  end

  describe '#call' do
    subject(:call) { new_service.call }

    let(:expected_response) do
      [
        DiskInfoService::TitleInfo.new(0, duration: '1:35:13', size: '1.8 GB', file_name: 'title_t00.mkv'),
        DiskInfoService::TitleInfo.new(1, duration: '1:53:42', size: '2.1 GB', file_name: 'title_t01.mkv'),
        DiskInfoService::TitleInfo.new(2, duration: '1:28:33', size: '1.6 GB', file_name: 'title_t02.mkv'),
        DiskInfoService::TitleInfo.new(3, duration: '1:31:24', size: '1.7 GB', file_name: 'title_t03.mkv')
      ].as_json
    end

    context 'when titles are found' do
      it 'returns a list of found titles' do
        expect(call.as_json).to eq expected_response
      end
    end
  end
end
