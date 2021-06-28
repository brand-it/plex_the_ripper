# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideoSearchQuery do
  before { create :config_the_movie_db }

  describe '#results', vcr: { record: :once, cassette_name: "#{described_class}/results" } do
    subject(:results) { described_class.new(query: 'stargate', page: page).results }

    let(:page) { 1 }

    it 'creates movies for each one it found' do
      expect { results }.not_to change(Movie, :count)
    end

    it 'creates tv for each one it found' do
      expect { results }.not_to change(Tv, :count)
    end

    it 'total results is limited to 4' do
      expect(results.count).to eq 15
    end

    it 'responds with movies' do
      expect(results.count { |r| r.type == 'Movie' }).to eq 9
    end

    it 'includes movie ids' do
      expect(results.map(&:the_movie_db_id)).to match_array [
        720_733, 784_993, 376_268, 13_001, 574_161,
        12_914, 226_412, 5148, 2290,
        2580, 72_925, 698_008, 46_852, 4629, 2164
      ]
    end

    it 'responds with tv shows' do
      expect(results.count { |r| r.type == 'Tv' }).to eq 6
    end
  end
end
