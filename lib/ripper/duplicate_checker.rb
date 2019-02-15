class DuplicateChecker
  class << self
    def perform
      duplicate_checker = DuplicateChecker.new
      duplicate_checker.ask_if_you_want_to_overwrite_movie
      duplicate_checker.ask_if_you_want_to_overwrite_tv_show
    end
  end

  def ask_if_you_want_to_overwrite_movie
    return if Config.configuration.type != :movie
    return if Config.configuration.videos.find_movie(Config.configuration.video_name).nil?

    yes = Shell.ask_value_required(
      "Is #{Config.configuration.video_name} of better quality? (Yes|No) ",
      type: TrueClass
    )
    yes ? delete_movie_files : abort
  end

  def ask_if_you_want_to_overwrite_tv_show
    return if Config.configuration.type != :tv
    return if find_tv_episodes.empty?

    episode = find_tv_episodes.first
    episodes = find_tv_episodes.map(&:number)

    yes = Shell.ask_value_required(
      "Duplicates found do you want to replace #{episode.season.tv_show.title}"\
      " Season #{episode.season.number} Episodes #{episodes.min} to #{episodes.max}? (Yes|No) ",
      type: TrueClass
    )
    yes ? delete_tv_files : abort
  end

  def find_tv_episodes
    videos = Config.configuration.videos
    tv_show = videos.find_tv_show(Config.configuration.video_name)
    return [] if tv_show.nil?

    season = tv_show.find_season(Config.configuration.tv_season)
    return [] if season.nil?

    season.episodes.select do |episode|
      min = Config.configuration.episode
      max = min + Config.configuration.total_episodes
      episode.number >= min && episode.number <= max
    end
  end

  def abort
    raise(
      Ripper::Abort,
      "Can't Rip #{Config.configuration.video_name} all ready has been ripped"
    )
  end

  def delete_movie_files
    Logger.info(
      'OK we will overwrite the current one'\
      ' we have on file with this movie info'
    )
    FileUtils.rm_rf(AskForFilePathBuilder.path)
  end

  def delete_tv_files
    find_tv_episodes.each do |episode|
      FileUtils.rm_rf(episode.file_path)
      Logger.info("Deleted #{episode.file_path}")
    end
  end
end
