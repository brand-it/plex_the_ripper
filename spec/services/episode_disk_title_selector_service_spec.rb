# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EpisodeDiskTitleSelectorService do
  describe '#call' do
    subject(:call) { described_class.new(episodes:, disk:).call }

    context 'when there is a single disk_title' do
      let(:episodes) { build_stubbed_list(:episode, 3, season:, runtime: 10.minutes) }
      let(:season) { build_stubbed(:season, tv:) }
      let(:tv) { build_stubbed(:tv) }
      let(:disk) { build_stubbed(:disk, disk_titles: [disk_title]) }
      let(:disk_title) { build_stubbed(:disk_title, duration: 10.minutes) }

      it { expect(call.first).to be_a(described_class::Info) }
      it { expect(call.first.disk_title.id).to eq(disk_title.id) }
      it { expect(call.first.episode.id).to eq(episodes.first.id) }
    end

    context 'when there are more then one disk title' do
      let(:episodes) { build_stubbed_list(:episode, 3, season:, runtime: 10.minutes) }
      let(:season) { build_stubbed(:season, tv:) }
      let(:tv) { build_stubbed(:tv) }
      let(:disk) { build_stubbed(:disk, disk_titles: [disk_title_a, disk_title_b]) }
      let(:disk_title_a) { build_stubbed(:disk_title, duration: 10.minutes) }
      let(:disk_title_b) { build_stubbed(:disk_title, duration: 10.minutes) }

      it { expect(call.first.episode.id).to eq(episodes.first.id) }
      it { expect(call.first.disk_title.id).to eq(disk_title_a.id) }
      it { expect(call.second.episode.id).to eq(episodes.second.id) }
      it { expect(call.second.disk_title.id).to eq(disk_title_b.id) }
      it('does not assocate a disk_title') { expect(call.third.disk_title).to be_nil }
    end
  end
end
