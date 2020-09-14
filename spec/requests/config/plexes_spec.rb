# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/config/plexes', type: :request do
  # Config::Plex. As you add validations to Config::Plex, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Config::Plex.create! valid_attributes
      get config_plex_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      create(:config_plex)
      get config_plex_url
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_config_plex_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      create(:config_plex)
      get edit_config_plex_url
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Config::Plex' do
        expect do
          post config_plex_url, params: { config_plex: valid_attributes }
        end.to change(Config::Plex, :count).by(1)
      end

      it 'redirects to the created config_plex' do
        post config_plex_url, params: { config_plex: valid_attributes }
        expect(response).to redirect_to(config_plex_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Config::Plex' do
        expect do
          post config_plex_url, params: { config_plex: invalid_attributes }
        end.to change(Config::Plex, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post config_plex_url, params: { config_plex: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested config_plex' do
        plex = Config::Plex.create! valid_attributes
        patch config_plex_url(config_plex), params: { config_plex: new_attributes }
        plex.reload
        skip('Add assertions for updated state')
      end

      it 'redirects to the config_plex' do
        plex = Config::Plex.create! valid_attributes
        patch config_plex_url(config_plex), params: { config_plex: new_attributes }
        plex.reload
        expect(response).to redirect_to(config_plex_url(plex))
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        Config::Plex.create! valid_attributes
        patch config_plex_url(config_plex), params: { config_plex: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested config_plex' do
      Config::Plex.create! valid_attributes
      expect do
        delete config_plex_url(config_plex)
      end.to change(Config::Plex, :count).by(-1)
    end

    it 'redirects to the config_plexes list' do
      Config::Plex.create! valid_attributes
      delete config_plex_url(config_plex)
      expect(response).to redirect_to(config_plex_url)
    end
  end
end
