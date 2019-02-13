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
    yes ? delete_files : abort
  end

  def ask_if_you_want_to_overwrite_tv_show
    return if Config.configuration.type != :tv

    name = [
      Config.configuration.tv_shows_directory_name,
      Config.configuration.video_name,
      Config.configuration.tv_season_to_word,
      Config.configuration.disc_number_to_word
    ].join('/')

    yes = Shell.ask_value_required(
      "Is #{name} of better quality? (Yes|No) ",
      type: TrueClass
    )
    yes ? delete_files : abort
  end

  def abort
    raise(
      Ripper::Abort,
      "Can't Rip #{Config.configuration.video_name} all ready has been ripped"
    )
  end

  def delete_files
    Logger.info(
      'OK we will overwrite the current one'\
      ' we have on file with this movie info'
    )
    FileUtils.rm_rf(FilePathBuilder.path)
  end
end
