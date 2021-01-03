# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Seasons', type: :request do
  let(:tv) { create :tv, the_movie_db_id: 4629 }
  let(:season) { create :season, season_number: 1, tv: tv }

  describe 'POST /update' do
    context 'with valid parameters' do
      subject(:patch_season) do
        VCR.use_cassette('the_movie_db/season') do
          patch season_url(season), params: { season: { somthing: 1 } }
        end
      end

      before { create :config_the_movie_db }

      it 'redirects to the updated sesson' do
        patch_season
        expect(response).to redirect_to(season_url(season))
      end
    end
  end
end
