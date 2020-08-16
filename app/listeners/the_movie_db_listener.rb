# frozen_string_literal: true

class TheMoveDbListener
  def movie_saving(movie)
    movie.attributes = the_movie_db_movie.to_h
  end

  private

  def the_movie_db_movie
    TheMovieDb::Movie.new(movie_id: the_movie_db_id).results
  end
end
