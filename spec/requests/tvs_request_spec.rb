# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tvs', type: :request do
  let(:valid_attributes) do
    {
      the_movie_db_id: 4629
    }
  end

  let(:invalid_attributes) do
    {
      the_movie_db_id: nil,
      name: nil,
      original_name: nil
    }
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      subject(:post_tv) do
        VCR.use_cassette('the_movie_db/tv') do
          post tvs_url, params: { tv: valid_attributes }
        end
      end

      before { create :config_the_movie_db, settings: { api_key: '213' } }

      it 'creates a new TV' do
        expect { post_tv }.to change(Tv, :count).by(1)
      end

      it 'redirects to the created user' do
        post_tv
        expect(response).to redirect_to(tv_url(Tv.last))
      end
    end

    context 'with invalid parameters' do
      subject(:post_tv) { post tvs_url, params: { tv: invalid_attributes } }

      it 'does not create a new TV' do
        expect { post_tv }.to change(Tv, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post_tv
        expect(response).to be_successful
      end
    end
  end
end
