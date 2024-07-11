# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MkvMaker::Version do
  describe '#results', :vcr do
    subject(:results) { described_class.new.results }

    it 'returns the current version' do
      expect(results).to eq '1.17.7'
    end
  end
end
