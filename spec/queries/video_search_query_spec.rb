# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideoSearchQuery do
  before { create :config_the_movie_db }

  describe '#results', vcr: { record: :once } do
    subject(:results) { described_class.new(query: 'stargate').results }

    it 'creates movies for each one it found' do
      expect { results }.to change(Movie, :count).by(9)
    end

    it 'creates tv for each one it found' do
      expect { results }.to change(Tv, :count).by(6)
    end
  end
end
