# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/config/plexes' do
  before { create(:config_make_mkv) }

  # let(:valid_attributes) do
  #   { config_plex: {} }
  # end

  # let(:invalid_attributes) do
  #   { config_plex: {} }
  # end

  # describe 'GET /index' do
  #   it 'renders a successful response' do
  #     Config::Plex.create! valid_attributes
  #     get config_plex_url
  #     expect(response).to be_successful
  #   end
  # end

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
end
