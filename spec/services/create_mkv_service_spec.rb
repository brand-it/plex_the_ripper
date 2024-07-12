# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateMkvService do
  let(:service) { described_class.new(disk_title:) }
  let(:disk_title) { build_stubbed(:disk_title) }

  before { create(:config_make_mkv) }

  describe '#call' do
    subject(:call) { service.call }

    context 'when the disk title is valid' do
      let(:disk_title) { build_stubbed(:disk_title, :with_movie) }

      before { allow(service).to receive(:cmd).and_return('ls /not-a-real-folder') }

      it 'responds with a result object' do
        expect(call).to eq(described_class::Result.new(disk_title.tmp_plex_path, false))
      end
    end
  end
end
