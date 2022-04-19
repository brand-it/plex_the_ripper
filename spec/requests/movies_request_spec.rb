# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  before { create :config_make_mkv }

  describe 'GET /show' do
    let(:movie) { create(:movie) }

    before { get movie_url(movie) }

    it { expect(response).to have_http_status :ok }
  end
end
