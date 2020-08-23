# frozen_string_literal: true

module TheMovieDbHelper
  HOST = 'www.themoviedb.org'

  def link_to_movie_db_seasons(tv_id, season_number, text: 'view more')
    link_to text, "https://#{HOST}/tv/#{tv_id}/season/#{season_number}", target: :blank
  end

  def link_to_movie_db_tv(tv_id, text: 'view more')
    link_to text, "https://#{HOST}/tv/#{tv_id}", target: :blank
  end

  def link_to_movie_db_movie(movie_id, text: 'view more')
    link_to text, "https://#{HOST}/movie/#{movie_id}", target: :blank
  end

  def link_to_movie_db_episode(tv_id, season_number, episode_number, text: 'view more')
    link_to text, "https://#{HOST}/tv/#{tv_id}/season/#{season_number}/episode/#{episode_number}", target: :blank
  end
end
