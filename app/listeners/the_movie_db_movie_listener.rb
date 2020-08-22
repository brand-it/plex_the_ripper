# frozen_string_literal: true

class TheMovieDbMovieListener
  PERMITTED_PARAMS = %i[title original_title release_date poster_path backdrop_path overview].freeze

  def movie_saving(movie)
    return if movie.the_movie_db_id.nil?

    db_movie = TheMovieDb::Movie.new(movie.the_movie_db_id).results
    movie.attributes = movie_params(db_movie)
  end

  private

  def movie_params(db_movie)
    db_movie.to_h.slice(*PERMITTED_PARAMS)
  end
end
