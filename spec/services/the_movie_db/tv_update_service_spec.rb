# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::TvUpdateService, type: :service do
  before { create :config_the_movie_db }

  let(:tv) { build_stubbed(:tv, the_movie_db_id: 4629) }
  let(:new_description_class) { described_class.new(tv) }

  describe '.call', vcr: { record: :new_episodes, cassette_name: "#{described_class}/_call" } do
    subject(:call) { new_description_class.call }

    it 'updates the synced_on value' do
      expect { call }.to change(tv, :synced_on).from(nil)
    end

    it 'updates the the title' do
      expect { call }.to change(tv, :title).from(tv.title).to(new_description_class.db_tv['name'])
    end

    it 'transforms episode_distribution_runtime' do
      expect do
        call
      end.to change(tv, :episode_distribution_runtime).from(tv.episode_distribution_runtime)
                                                      .to(new_description_class.db_tv['episode_run_time'].sort)
    end
  end
end
