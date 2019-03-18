# frozen_string_literal: true

RSpec.shared_context 'the_movie_db' do
  before do
    # This is a validation check to make sure the API key we used works.
    # The only reason I am stubbing out this lower level call is to allow for the do block that
    # is only being used in the TheMovieDBCo{nfig#valid_api_key?. Just an extra check because why
    # not make that happen.

    allow(Config.configuration.the_movie_db_config).to receive(:valid_api_key?).and_return(true)
  end
  let(:tv_id) { 12_662 } # https://www.themoviedb.org/tv/12662
  let(:movie_id) { 299_534 }
  let(:season_number) { 1 }
  let(:episode_number) { 1 }
  before { Config.configuration.the_movie_db_config.api_key = 'something' }
  let(:the_movie_db_tv) do
    VCR.use_cassette 'the_movie_db/tv_1' do
      TheMovieDB::TV.find(tv_id)
    end
  end

  let(:the_movie_db_season) do
    VCR.use_cassette 'the_movie_db/tv_1/season_1' do
      the_movie_db_tv.seasons.find(tv_id: 122, season_number: 22)
    end
  end

  let(:the_movie_db_movie) do
    VCR.use_cassette 'the_movie_db/movie_1' do
      TheMovieDB::Movie.find(movie_id)
    end
  end
end
