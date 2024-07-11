# frozen_string_literal: true

module TheMovieDb
  class VideoListener
    def tv_saving(tv)
      TheMovieDb::TvUpdateService.call(tv, tv.the_movie_db_details)
    end

    def movie_saving(movie)
      TheMovieDb::MovieUpdateService.call(movie, movie.the_movie_db_details)
    end
  end
end
