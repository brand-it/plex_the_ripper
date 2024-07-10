# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideoSearchQuery do
  before { create(:config_the_movie_db) }

  describe '#results', vcr: { record: :once, cassette_name: "#{described_class}/results" } do
    subject(:results) { described_class.new(query: 'stargate', page:).results }

    let(:page) { 1 }

    it 'creates movies for each one it found' do
      expect { results }.not_to change(Movie, :count)
    end

    it 'creates tv for each one it found' do
      expect { results }.not_to change(Tv, :count)
    end

    it 'total results is limited to 19' do
      expect(results.count).to eq 19
    end

    it 'responds with movies' do
      expect(results.count { |r| r.type == 'Movie' }).to eq 14
    end

    it 'includes movie ids' do
      expect(results.map(&:the_movie_db_id).sort).to match(
        [2164, 2290, 2580, 4629, 5148, 12_914, 13_001, 72_925, 226_412, 376_268, 720_733, 784_993, 873_627, 956_729,
         1_052_378, 1_090_964, 1_172_196, 1_173_147, 1_315_267].sort
      )
    end

    it 'responds with tv shows' do
      expect(results.count { |r| r.type == 'Tv' }).to eq 5
    end
  end
end
