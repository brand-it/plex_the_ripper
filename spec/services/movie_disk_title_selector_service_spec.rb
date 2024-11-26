# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovieDiskTitleSelectorService do
  describe '#call' do
    subject(:call) { described_class.new(movie:, disk:).call }

    before { movie.association(:ripped_disk_titles).loaded! }

    let(:movie) { build_stubbed(:movie, movie_runtime: 10.seconds) }
    let(:disk) { build_stubbed(:disk, disk_titles: [disk_title]) }
    let(:disk_title) { build_stubbed(:disk_title, duration: 10.seconds) }

    it { expect(call.first).to be_a(described_class::Info) }
    it { expect(call.first.disk_title.id).to eq(disk_title.id) }
    it { expect(call.first.extra_type).to eq('feature_films') }

    context 'when there are multiple disk titles that could match' do
      let(:movie) { build_stubbed(:movie, movie_runtime: 10.seconds) }
      let(:disk) { build_stubbed(:disk, disk_titles: [disk_title_a, disk_title_b]) }
      let(:disk_title_a) { build_stubbed(:disk_title, duration: 10.seconds) }
      let(:disk_title_b) { build_stubbed(:disk_title, duration: 10.seconds) }

      it { expect(call.first.disk_title.id).to eq(disk_title_a.id) }
      it { expect(call.first.extra_type).to eq('feature_films') }
      it { expect(call.second.disk_title.id).to eq(disk_title_b.id) }
      it { expect(call.second.extra_type).to be_nil }
    end
  end
end
