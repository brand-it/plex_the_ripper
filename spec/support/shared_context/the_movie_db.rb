# frozen_string_literal: true

RSpec.shared_context 'the_movie_db' do
  let(:stub_valid_api_key) do
    allow(Config.configuration.the_movie_db_config).to receive(:valid_api_key?).and_return(true)
    set_api_key
  end
  let(:tv_id) { 12_662 } # https://www.themoviedb.org/tv/12662
  let(:movie_id) { 299_534 }
  let(:season_number) { 1 }
  let(:episode_number) { 1 }
  let(:set_api_key) { Config.configuration.the_movie_db_config.api_key = 'something' }
  let(:the_movie_db_tv) do
    VCR.use_cassette 'the_movie_db/tv_1' do
      TheMovieDB::TV.find(tv_id)
    end
  end

  let(:the_movie_db_season) do
    VCR.use_cassette 'the_movie_db/tv_1/season_1' do
      TheMovieDB::Season.find(tv: TheMovieDB::TV.new(id: tv_id), season_number: season_number)
    end
  end

  let(:the_movie_db_movie) do
    VCR.use_cassette 'the_movie_db/movie_1' do
      TheMovieDB::Movie.find(movie_id)
    end
  end
end
