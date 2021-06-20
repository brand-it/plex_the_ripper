# frozen_string_literal: true

# https://developers.themoviedb.org/3/movies/get-movie-details
module TheMovieDb
  class Movie < Base
    param :movie_id, Types::Integer

    private

    def path
      "movie/#{movie_id}"
    end
  end
end
