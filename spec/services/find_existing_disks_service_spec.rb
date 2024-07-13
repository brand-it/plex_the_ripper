# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindExistingDisksService do
  include_context 'with mkv_stubbs'

  describe '#call' do
    subject(:call) { described_class.call }

    context 'when no disks exist' do
      it { is_expected.to eq [] }
    end

    context 'when disk exists and it matches' do
      let!(:disk) { create(:disk, ejected: false, name: '07804', disk_name: '/dev/rdisk8') }

      it { expect(call.map(&:id)).to match [disk.id] }
    end

    context 'when disk exists but the disk is ejected' do
      before { create(:disk, ejected: true, name: '07804', disk_name: '/dev/rdisk8') }

      it { is_expected.to eq [] }
    end
  end
end
