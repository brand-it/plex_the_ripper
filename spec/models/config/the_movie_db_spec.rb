# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::TheMovieDb, type: :model do
  let(:config) { build_stubbed :config_the_movie_db }

  describe '#default_settings' do
    let(:expected_settings) { OpenStruct.new(dark_mode: true) }

    it 'has defaults' do
      expect(config.settings).to eq expected_settings
    end
  end
end
