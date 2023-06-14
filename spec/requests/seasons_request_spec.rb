# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Seasons' do
  before { create(:config_make_mkv) }

  let(:tv) { create(:tv, the_movie_db_id: 4629) }
  let(:season) { create(:season, season_number: 1, tv: tv) }

  describe 'POST /update', :vcr do
    context 'with valid parameters' do
      subject(:patch_season) { patch season_url(season), params: { season: { somthing: 1 } } }

      before { create(:config_the_movie_db) }

      it 'redirects to the updated sesson' do
        patch_season
        expect(response).to redirect_to(season_url(season))
      end
    end
  end
end
