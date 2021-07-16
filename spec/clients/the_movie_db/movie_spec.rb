# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::Movie do
  before { create :config_the_movie_db }

  describe '#results', :vcr do
    subject(:results) { described_class.new(577_922).results }

    it 'responds with success' do
      expect(results.title).to eq 'Tenet'
    end
  end
end
