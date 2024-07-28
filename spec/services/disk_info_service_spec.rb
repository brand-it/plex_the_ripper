# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiskInfoService do
  include_context 'with mkv_stubbs'
  before { allow(new_service).to receive(:info).and_return(title_info_object) }

  let(:config_make_mkv) { create(:config_make_mkv) }
  let(:new_service) { described_class.new(config_make_mkv:, disk_name: '/dev/disk2') }

  describe '#results' do
    subject(:call) { new_service.results }

    let(:expected_response) do
      [
        DiskInfoService::TitleInfo.new(0, duration: '1:35:13', size: '1.8 GB', filename: 'title_t00.mkv'),
        DiskInfoService::TitleInfo.new(1, duration: '1:53:42', size: '2.1 GB', filename: 'title_t01.mkv'),
        DiskInfoService::TitleInfo.new(2, duration: '1:28:33', size: '1.6 GB', filename: 'title_t02.mkv'),
        DiskInfoService::TitleInfo.new(3, duration: '1:31:24', size: '1.7 GB', filename: 'title_t03.mkv')
      ].as_json
    end

    context 'when titles are found' do
      it 'returns a list of found titles' do
        expect(call.as_json).to eq expected_response
      end
    end
  end
end
