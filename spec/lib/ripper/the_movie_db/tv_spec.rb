# frozen_string_literal: true

describe TheMovieDb::TV do
  include_context 'the_movie_db'
  before { stub_valid_api_key }
  describe '.find' do
    # kinda of confusing but the find is a shared vcr, we are going to test it here however
    subject(:find) { the_movie_db_tv }

    it { expect(find).to be_a TheMovieDb::TV }
  end

  describe '#runtime' do
    subject(:runtime) { the_movie_db_tv.runtime }

    it { expect(runtime).to eq(max: 30, min: 25) }
  end

  describe '#find_season_by_number' do
    subject(:find_season_by_number) { the_movie_db_tv.find_season_by_number(1) }
    it { expect(find_season_by_number).to be_a(TheMovieDb::Season) }
  end

  describe '#find_season_by_number.find_episode_by_number' do
    subject(:find_episode_by_number) do
      VCR.use_cassette 'the_movie_db/find_season_by_number.find_episode_by_number' do
        the_movie_db_tv.find_season_by_number(1).find_episode_by_number(1)
      end
    end
    it { expect(find_episode_by_number).to be_a(TheMovieDb::Episode) }
  end
end
