# frozen_string_literal: true

class TheMovieDbListener
  def movie_saving(movie)
    movie.attributes = serialize(movie)
  end

  private

  def serialize(movie)
    keys = movie.attributes.keys.map(&:to_sym)
    results = the_movie_db_movie(movie)
    results.to_h.slice(*keys).except(:id).tap do |hash|
      hash[:poster_url] = "https://image.tmdb.org/t/p/w500#{results.poster_path}" if results.poster_path
      hash[:backdrop_url] = "https://image.tmdb.org/t/p/w500#{results.backdrop_path}" if results.backdrop_path
    end
  end

  def the_movie_db_movie(movie)
    TheMovieDb::Movie.new(movie.the_movie_db_id).results
  end
end
