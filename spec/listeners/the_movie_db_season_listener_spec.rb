# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TheMovieDbSeasonListener do
  let(:tv) { build_stubbed :tv, the_movie_db_id: 4629 }
  let(:season) { build :season, season_number: 1, tv: tv }

  before { create :config_the_movie_db }

  describe '#season_saving', :vcr do
    subject(:season_saving) { described_class.new.season_saving(season) }

    let(:expected_attributes) do
      {
        'id' => nil,
        'name' => 'Season 1',
        'overview' =>
  'The first season of the military science fiction television series Stargate SG-1'\
  ' commenced airing on the Showtime channel in the United States on July 27, 1997,'\
  ' concluded on the same channel on March 6, 1998, and contained 22 episodes. The '\
  'show itself is a spin off from the 1994 hit movie, Stargate written by Dean Devlin'\
  ' and Roland Emmerich. Stargate SG-1 re-introduced supporting characters from the'\
  " film universe, such as Jonathan \"Jack\" O'Neill and Daniel Jackson and included "\
  "new characters such as Teal'c, George Hammond and Samantha \"Sam\" Carter. The first"\
  ' season was about a military-science expedition team discovering how to use the ancient'\
  ' device, named the Stargate, to explore the galaxy. However, they encountered a powerful'\
  " enemy in the film named the Goa'uld, which is bent on destroying Earth and all that"\
  ' opposes them.',
        'poster_path' => '/tiib6A0kZ0NoUeuUbcU0hIu2jlM.jpg',
        'the_movie_db_id' => season.the_movie_db_id,
        'season_number' => 1,
        'air_date' => '1997-07-27',
        'tv_id' => tv.id,
        'created_at' => nil,
        'updated_at' => nil
      }
    end

    it 'updates attributes using season name' do
      season_saving
      expect(season.attributes.as_json).to eq expected_attributes
    end

    it 'creates seasons' do
      expect { season_saving }.to change { season.episodes.size }.from(0).to(22)
    end
  end
end
