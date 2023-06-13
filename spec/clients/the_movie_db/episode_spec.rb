# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::Episode do
  before { create(:config_the_movie_db) }

  describe '#results', :vcr do
    subject(:results) { described_class.new(66_732, 1, 1).results }

    it 'responds with success' do
      expect(results['id']).to eq 1_198_665
    end
  end
end
