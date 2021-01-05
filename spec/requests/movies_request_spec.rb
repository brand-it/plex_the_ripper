# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  let(:movie) { create :movie }

  # pending "add some examples to (or delete) #{__FILE__}"

  describe 'get /movies/:id/select' do
    subject(:select) { get select_movie_path(season) } }
    subject(:patch_season) { patch season_url(season), params: { season: { somthing: 1 } } }

  end
end
