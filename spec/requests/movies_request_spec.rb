# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Movies', type: :request do
  let(:tv) { create :tv, the_movie_db_id: 4629 }
  let(:season) { create :season, season_number: 1, tv: tv }

  pending "add some examples to (or delete) #{__FILE__}"
  # describe 'get /select/:the_movie_db_id' do
  # end
end
