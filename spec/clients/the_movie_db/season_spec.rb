# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::Season do
  before { create :config_the_movie_db }

  describe '#results', :vcr do
    subject(:results) { described_class.new(66_732, 1).body }

    it 'responds with success' do
      expect(results._id).to eq '57599ae2c3a3684ea900242d'
    end
  end
end
