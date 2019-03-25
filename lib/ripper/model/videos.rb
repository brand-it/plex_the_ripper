# frozen_string_literal: true

class Videos < Model
  columns(movies: Array, tv_shows: Array)
  class << self
    def load
      tv_shows = Dir.glob(
        File.join(
          Config.configuration.media_directory_path,
          Config.configuration.tv_shows_directory_name,
          '**', '*.mkv'
        )
      )
      movies = Dir[
        File.join(
          Config.configuration.media_directory_path,
          Config.configuration.movies_directory_name,
          '**', '*.mkv'
        )
      ]
      { movies: movies, tv_shows: tv_shows }
    end

    # This get the Name of the movie or folder that the movies are in.
    # mkv_path should be the absolute path of where the mvk video is
    # directory_name should be "TV Shows" or "Movies". But that can be custom
    # depending on the user settings
    def get_name_from_path(mkv_path, directory_name)
      name_path = mkv_path.split(directory_name).last
      name_path.split('/').reject { |x| x == '' }.first.strip
    end
  end

  def movie_present?(name:)
    find_movie(name) != nil
  end

  def tv_show_present?(title:)
    tv_show = find_tv_show(title)
    return false if tv_show.nil?

    season = tv_show.find_season(Config.configuration.tv_season)
    return false if season.nil?

    episode = season.find_episode(Config.configuration.episode)
    episode != nil
  end

  def find_tv_show(title)
    tv_shows.find { |tv| tv.title == title }
  end

  def find_movie(name)
    movies.find { |m| m.name == name }
  end

  def add_movie(name:)
    movie = find_movie(name)
    movie ||= movies.push(Movie.new(name: name)).last
    movie
  end

  def add_tv_show(title:, season:, episode:, file_path:, directory:, episode_name:)
    tv_show = find_tv_show(title)
    tv_show ||= tv_shows.push(
      TVShow.new(title: title, video: self, directory: directory)
    ).last
    season = tv_show.add_season(season)
    season.add_episode(episode, episode_name, file_path)
    tv_show
  end

  def any?
    movies.any? || tv_shows.any?
  end
end
