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
      expect(results.count).to eq 4
    end

    it 'responds with movies' do
      expect(results.count { |r| r.type == 'Movie' }).to eq 3
    end

    it 'includes movie ids' do
      expect(results.map(&:the_movie_db_id)).to eq [2164, 226_412, 4629, 574_161]
    end

    it 'responds with tv shows' do
      expect(results.count { |r| r.type == 'Tv' }).to eq 1
    end

    context 'when next page' do
      let(:page) { 2 }

      it 'total results is limited to 4' do
        expect(results.map(&:the_movie_db_id)).to eq [2290, 5148, 376_268, 12_914]
      end
    end
  end
end
