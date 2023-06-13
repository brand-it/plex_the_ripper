# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDbSeasonListener do
  let(:tv) { build_stubbed(:tv, the_movie_db_id: 4629) }
  let(:season) { build(:season, season_number: 1, tv: tv) }

  before { create(:config_the_movie_db) }

  describe '#season_saving', :vcr do
    subject(:season_saving) { described_class.new.season_saving(season) }

    let(:expected_attributes) do
      {
        'id' => nil,
        'name' => 'Season 1',
        'overview' => '',
        'poster_path' => '/tiib6A0kZ0NoUeuUbcU0hIu2jlM.jpg',
        'the_movie_db_id' => season.the_movie_db_id,
        'season_number' => 1,
        'air_date' => '1997-07-27',
        'tv_id' => tv.id,
        'created_at' => nil,
        'updated_at' => nil
      }
    end

    it 'updates attributes using season name' do
      season_saving
      expect(season.attributes.as_json).to eq expected_attributes
    end

    it 'creates seasons' do
      expect { season_saving }.to change { season.episodes.size }.from(0).to(22)
    end
  end
end
