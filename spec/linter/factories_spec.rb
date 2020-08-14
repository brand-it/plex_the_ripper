# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FactoryBot', type: :model do
  let(:config) { build_stubbed :config_the_movie_db }

  describe '#factory_bot' do
    it 'does not raise any linting errors' do
      FactoryBot.lint(traits: true)
      expect(true).to eq true # rubocop:disable RSpec/ExpectActual
    rescue => e # rubocop:disable Style/RescueStandardError
      raise e
    end
  end
end
