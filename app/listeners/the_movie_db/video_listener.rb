# frozen_string_literal: true

module TheMovieDb
  class VideoListener
    def tv_validating(tv)
      TheMovieDb::TvUpdateService.call(tv)
    end

    def movie_validating(movie)
      TheMovieDb::MovieUpdateService.call(movie)
    end
  end
end
