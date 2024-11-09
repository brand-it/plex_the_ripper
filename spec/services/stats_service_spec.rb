# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatsService do
  describe '#call' do
    subject(:call) { described_class.new(list).call }

    context 'when a bunch of values are given' do
      let(:list) { [2579, 2498, 2549, 2575, 2573, 2486, 2518, 2580, 2494, 2577, 2575, 2575, 2577, 2443, 2578, 2441, 2521, 2561, 2580, 2534, 2571, 2565, 5062] }
      let(:differences) do
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 35, 36, 37, 39, 40, 41, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 67, 71, 73,
         75, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 91, 92, 93, 94, 106, 108, 118, 120, 122, 124, 128, 130, 132, 134, 135, 136, 137, 138, 139, 2482, 2483, 2484, 2485, 2487, 2489, 2491, 2497, 2501, 2513, 2528, 2541, 2544,
         2564, 2568, 2576, 2619, 2621]
      end

      it { is_expected.to eq(described_class::Info.new(2575, 2573.7497394471216, 62.5, 62.79612125669019, 139, 2621, differences)) }
    end

    context 'when nothing is given' do
      let(:list) { [] }

      it { is_expected.to eq(described_class::Info.new(nil, nil, nil, nil, nil, nil, [])) }
    end
  end
end
