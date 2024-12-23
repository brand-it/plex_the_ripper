# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MkvInstaller::Base do
  describe '#version', :vcr do
    subject(:version) { described_class.new.send(:version) }

    it 'responds with a information object' do
      expect(version).to eq '1.17.7'
    end
  end
end
