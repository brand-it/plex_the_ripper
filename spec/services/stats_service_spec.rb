# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatsService do
  describe '#call' do
    subject(:call) { described_class.new(list).call }

    context 'when a bunch of values are given' do
      let(:list) { [2579, 2498, 2549, 2575, 2573, 2486, 2518, 2580, 2494, 2577, 2575, 2575, 2577, 2443, 2578, 2441, 2521, 2561, 2580, 2534, 2571, 2565, 5062] }

      it { is_expected.to eq(described_class::Info.new(2575, 2573.7497394471216, 62.5, 62.79612125669019, 139)) }
    end

    context 'when nothing is given' do
      let(:list) { [] }

      it { is_expected.to eq(described_class::Info.new(nil, nil, nil, nil, nil)) }
    end
  end
end
