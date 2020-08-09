# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FactoryBot', type: :model do
  let(:config) { build_stubbed :config_the_movie_db }

  describe '#factory_bot' do
    it 'does not raise any linting errors' do
      expect { FactoryBot.lint(traits: true) }.not_to raise_error
    end
  end
end
