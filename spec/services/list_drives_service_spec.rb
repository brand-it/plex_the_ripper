# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListDrivesService do
  include_context 'mkv_stubbs'
  before { allow(new_service).to receive(:info).and_return(drive_info_object) }

  let(:config_make_mkv) { create :config_make_mkv }
  let(:new_service) { described_class.new(config_make_mkv: config_make_mkv) }

  describe '#call' do
    subject(:call) { new_service.call }

    let(:expected_response) do
      MkvParser::DRV.new(
        '0', '2', '999', '1', 'BD-ROM MATSHITA BD-CMB UJ141EL 1.10', '18384_SCN', '/dev/rdisk3'
      )
    end

    it 'responds with the first Drive it can find' do
      expect(call).to eq expected_response
    end
  end
end
