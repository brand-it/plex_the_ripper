# frozen_string_literal: true

module TheMovieDb
  class MovieListener
    def movie_saving(movie)
      TheMovieDb::MovieUpdateService.call(movie)
    end
  end
end
