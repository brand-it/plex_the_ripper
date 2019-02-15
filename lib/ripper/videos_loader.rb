class VideosLoader
  Videos = Struct.new(:movies, :tv_shows)
  TV_SHOW_PATTERN_ONE = /\A(?<name>.*)\s\-\ss(?<season>\d\d)e(?<episode>\d\d)/.freeze
  TV_SHOW_PATTERN_TWO = /\A(?<name>.*)\ss(?<season>\d\d)e(?<episode>\d\d)/.freeze
  TV_SHOW_PATTERN_THREE = /\A(?<name>.*)\-s(?<season>\d\d)e(?<episode>\d\d)/.freeze

  class << self
    def perform
      return if Config.configuration.videos.any?

      sleep 1 until File.exist?(Config.configuration.media_directory_path)
      Logger.info('Started Loading Videos')

      file_checker = VideosLoader.new
      file_checker.load_videos
    end
  end

  def load_videos
    videos = all_videos
    videos.movies.each do |movie_path|
      movie = parse_movie_mkv_path(movie_path)
      begin
        Config.configuration.videos.add_movie(movie)
      rescue Model::Validation => exception
        Logger.error("#{exception.message} #{movie_path} #{movie}")
      end
    end
    videos.tv_shows.each do |tv_show_path|
      tv_show = parse_tv_show_mkv_path(tv_show_path)
      begin
        Config.configuration.videos.add_tv_show(tv_show)
      rescue Model::Validation => exception
        Logger.error("#{exception.message} #{tv_show_path} #{tv_show}")
      end
    end
  end

  private

  def all_videos
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
    Videos.new(movies, tv_shows)
  end

  def parse_tv_show_mkv_path(mkv_path)
    name = get_name_from_path(mkv_path, Config.configuration.tv_shows_directory_name)
    match = match_tv_show(mkv_path)
    season = 0
    episode = 0
    if match.is_a?(Hash)
      warn_about_naming_issues(mkv_path, name, match[:name])
      season = match[:season].to_i
      episode = match[:episode].to_i
    end
    {
      title: name,
      season: season,
      episode: episode,
      file_path: mkv_path
    }
  end

  def parse_movie_mkv_path(mkv_path)
    file_name = File.basename(mkv_path, '.mkv').strip
    name = get_name_from_path(mkv_path, Config.configuration.movies_directory_name)
    warn_about_naming_issues(mkv_path, name, file_name)
    { name: name }
  end

  # This get the Name of the movie or folder that the movies are in.
  # mkv_path should be the absolute path of where the mvk video is
  # directory_name should be "TV Shows" or "Movies". But that can be custom
  # depending on the user settings
  def get_name_from_path(mkv_path, directory_name)
    name_path = mkv_path.split(directory_name).last
    name_path.split('/').reject { |x| x == '' }.first.strip
  end

  def warn_about_naming_issues(mkv_path, name_one, name_two)
    return if name_one.strip == name_two.strip

    Logger.warning(
      "#{mkv_path} expected to match but does not Please fix "\
      "#{name_one.inspect} != #{name_two.inspect}. Going to use #{name_one}",
      delayed: true
    )
  end

  def match_tv_show(mkv_path)
    basename = File.basename(mkv_path, '.mkv')
    [TV_SHOW_PATTERN_ONE, TV_SHOW_PATTERN_TWO, TV_SHOW_PATTERN_THREE].each do |pattern|
      match = basename.match(pattern)
      return match if match
    end
  end
end
