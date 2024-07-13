# frozen_string_literal: true

module TheMovieDb
  class VideoListener
    def tv_saving(tv)
      TheMovieDb::TvUpdateService.call(tv)
    end

    def movie_saving(movie)
      TheMovieDb::MovieUpdateService.call(movie)
    end
  end
end
