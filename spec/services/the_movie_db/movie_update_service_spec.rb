# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::MovieUpdateService, type: :service do
  before { create :config_the_movie_db }

  let(:movie) { build_stubbed(:movie, the_movie_db_id: 399_566) }
  let(:new_description_class) { described_class.new(movie: movie) }

  describe '.call', vcr: { record: :new_episodes, cassette_name: "#{described_class}/_call" } do
    subject(:call) { new_description_class.call }

    it 'updates the synced_on value' do
      expect { call }.to change(movie, :synced_on).from(nil)
    end

    it 'updates the the title' do
      expect { call }.to change(movie, :title).from(movie.title).to(new_description_class.db_movie[:title])
    end

    it 'transforms runtime to movie_runtime' do
      expect do
        call
      end.to change(movie, :movie_runtime).from(movie.movie_runtime).to(new_description_class.db_movie[:runtime].to_i)
    end
  end
end
