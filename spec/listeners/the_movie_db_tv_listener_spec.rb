# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDbTvListener do
  let(:tv) { build :tv, the_movie_db_id: 4629 }

  before { create :config_the_movie_db, settings: { api_key: '12345' } }

  describe '#tv_saving', use_vcr_cassette: 'the_movie_db/tv' do
    subject(:tv_saving) { described_class.new.tv_saving(tv) }

    let(:expected_attributes) do
      {
        'backdrop_path' => '/ul7W8lwLIgxre1LXigFw55upfZ5.jpg',
        'created_at' => nil,
        'disk_id' => nil,
        'episode_run_time' => [42, 60, 43, 45],
        'id' => nil,
        'name' => 'Stargate SG-1',
        'original_name' => 'Stargate SG-1',
        'overview' => 'The story of Stargate SG-1 begins about a year after '\
        'the events of the feature film, when the United States government '\
        'learns that an ancient alien device called the Stargate can access'\
        ' a network of such devices on a multitude of planets. SG-1 is an elite'\
        ' Air Force special operations team, one of more than two dozen teams '\
        'from Earth who explore the galaxy and defend against alien threats such'\
        " as the Goa'uld, Replicators, and the Ori.",
        'poster_path' => '/rst5xc4f7v1KiDiQjzDiZqLtBpl.jpg',
        'the_movie_db_id' => 4629,
        'updated_at' => nil,
        'first_air_date' => '1997-07-27'
      }
    end

    it 'updates attributes using tv name' do
      tv_saving
      expect(tv.attributes).to eq expected_attributes
    end

    it 'creates seasons' do
      expect { tv_saving }.to change { tv.seasons.size }.from(0).to(11)
    end
  end
end
