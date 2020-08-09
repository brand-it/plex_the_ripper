# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::User, type: :model do
  let(:config) { build_stubbed :config_user }
  describe '#default_settings' do
    let(:expected_settings) { OpenStruct.new(api_key: nil) }

    it 'has defaults' do
      expect(config.settings).to eq expected_settings
    end
  end
end
