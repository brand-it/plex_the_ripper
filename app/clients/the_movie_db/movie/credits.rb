# frozen_string_literal: true

# https://developers.themoviedb.org/3/movies/get-movie-credits
module TheMovieDb
  class Movie
    class Credits < TheMovieDb::Base
      param :movie_id, Types::Integer

      private

      def path
        "movie/#{movie_id}/credits"
      end
    end
  end
end
