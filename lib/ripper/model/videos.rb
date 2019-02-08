class Videos < Model
  columns(movies: Array, tv_shows: Array)

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

  def add_tv_show(title:, season:, episode:)
    tv_show = find_tv_show(title)
    tv_show ||= tv_shows.push(TVShow.new(title: title, video: self)).last
    season = tv_show.add_season(season)
    season.add_episode(episode)
    tv_show
  end
end
