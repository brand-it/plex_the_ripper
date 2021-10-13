# frozen_string_literal: true

# https://developers.themoviedb.org/3/movies/get-movie-release-dates
module TheMovieDb
  class Movie
    class ReleaseDates < TheMovieDb::Base
      param :movie_id, Types::Integer

      private

      def path
        "movie/#{movie_id}/release_dates"
      end
    end
  end
end
