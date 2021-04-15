# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::MovieUpdateService, type: :service do
  before { create :config_the_movie_db }

  let(:movie) { build_stubbed(:movie, the_movie_db_id: 399_566) }

  describe '.call', vcr: { record: :once } do
    subject(:call) { described_class.call(movie: movie) }

    it 'updates the synced_on value' do
      expect { call }.to change(movie, :synced_on).from(nil)
    end
  end
end
