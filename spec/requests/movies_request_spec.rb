# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  describe 'GET /show' do
    let(:movie) { create(:movie) }

    before { get movie_url(movie) }

    it { expect(response).to be_successful }
  end
end
