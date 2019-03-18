# frozen_string_literal: true

describe TheMovieDB::Movie do
  include_context 'the_movie_db'
  before { stub_valid_api_key }
  describe '.find' do
    # kinda of confusing but the find is a shared vcr, we are going to test it here however
    subject(:find) { the_movie_db_movie }

    it { expect(find).to be_a TheMovieDB::Movie }
  end

  describe '#runtime' do
    subject(:runtime) { the_movie_db_movie.runtime }

    it { expect(runtime).to eq(max: 180, min: 180) }
  end

  describe '.search' do
    subject(:search) do
      VCR.use_cassette 'the_movie_db/movie_search' do
        TheMovieDB::Movie.search('Super Man')
      end
    end
    it { expect(search.first).to be_a(TheMovieDB::Movie) }
  end
end
