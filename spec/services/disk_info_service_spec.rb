# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiskInfoService do
  include_context 'with mkv_stubbs'
  before { allow(new_service).to receive(:info).and_return(title_info_object) }

  let(:config_make_mkv) { create(:config_make_mkv) }
  let(:new_service) { described_class.new(config_make_mkv:, disk_name: '/dev/disk2') }

  describe '#call' do
    subject(:call) { new_service.call }

    let(:expected_response) do
      [
        {
          'id' => 0,
          'chapter_count' => 10,
          'duration' => '1:35:13',
          'size' => '1.8 GB',
          'bytes' => 1_947_029_504,
          'segment_count' => 1,
          'segement_map' => '1-10',
          'filename' => 'title_t00.mkv',
          'description' => '10 chapter(s), 1.8 GB'
        },
        {
          'id' => 1,
          'chapter_count' => 11,
          'duration' => '1:53:42',
          'size' => '2.1 GB',
          'bytes' => 2_321_354_752,
          'segment_count' => 1,
          'segement_map' => '1-11',
          'filename' => 'title_t01.mkv',
          'description' => '11 chapter(s), 2.1 GB'
        },
        {
          'id' => 2,
          'chapter_count' => 10,
          'duration' => '1:28:33',
          'size' => '1.6 GB',
          'bytes' => 1_810_173_952,
          'segment_count' => 1,
          'segement_map' => '1-10',
          'filename' => 'title_t02.mkv',
          'description' => '10 chapter(s), 1.6 GB'
        },
        {
          'id' => 3,
          'chapter_count' => 10,
          'duration' => '1:31:24',
          'size' => '1.7 GB',
          'bytes' => 1_870_516_224,
          'segment_count' => 1,
          'segement_map' => '1-10',
          'filename' => 'title_t03.mkv',
          'description' => '10 chapter(s), 1.7 GB'
        }
      ].as_json
    end

    context 'when titles are found' do
      it 'returns a list of found titles' do
        expect(call.as_json).to eq expected_response
      end
    end
  end
end
