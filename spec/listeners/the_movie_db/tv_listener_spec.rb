# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDb::TvListener do
  let(:tv) { build(:tv, the_movie_db_id: 4629) }

  before { create(:config_the_movie_db) }

  describe '#tv_saving', :vcr, freeze: Time.zone.local(1990) do
    subject(:tv_saving) { described_class.new.tv_saving(tv) }

    let(:expected_attributes) do
      {
        'id' => nil,
        'title' => 'Stargate SG-1',
        'original_title' => 'Stargate SG-1',
        'episode_first_air_date' => Date.parse('1997-07-27'),
        'poster_path' => '/9Jegw0yle4x8jlmLNZon37Os27h.jpg',
        'rating' => 'N/A',
        'backdrop_path' => '/li9SZBpVzJz81ouqifVuH5C7Nod.jpg',
        'episode_distribution_runtime' => [42, 43, 45, 60],
        'movie_runtime' => nil,
        'the_movie_db_id' => 4629,
        'disk_title_id' => nil,
        'popularity' => nil,
        'overview' => 'The story of Stargate SG-1 begins about a year after ' \
                      'the events of the feature film, when the United States government ' \
                      'learns that an ancient alien device called the Stargate can access' \
                      ' a network of such devices on a multitude of planets. SG-1 is an elite' \
                      ' Air Force special operations team, one of more than two dozen teams ' \
                      'from Earth who explore the galaxy and defend against alien threats such' \
                      " as the Goa'uld, Replicators, and the Ori.",
        'type' => 'Tv',
        'synced_on' => Time.zone.local(1990),
        'updated_at' => nil,
        'created_at' => nil,
        'release_date' => nil
      }.sort.to_h
    end

    it 'updates attributes using tv name' do
      tv_saving
      expect(tv.attributes.sort.to_h).to eq expected_attributes
    end

    it 'creates seasons' do
      expect { tv_saving }.to change { tv.seasons.size }.from(0).to(11)
    end
  end
end
