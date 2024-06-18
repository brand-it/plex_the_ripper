# frozen_string_literal: true

module TheMovieDb
  class MovieListener
    def movie_saving(movie)
      TheMovieDb::MovieUpdateService.call(movie, movie.the_movie_db_details)
    end
  end
end
