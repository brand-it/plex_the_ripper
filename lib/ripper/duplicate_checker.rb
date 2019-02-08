class DuplicateChecker
  def perform
    duplicate_checker = DuplicateChecker.new
    duplicate_checker.ask_if_you_want_to_overwrite_movie
    duplicate_checker.ask_if_you_want_to_overwrite_tv_show
  end

  def ask_if_you_want_to_overwrite_movie
    return if Config.configuration.type != :movie
    return unless already_ripped?

    if ask_overwrite_question
      Logger.info(
        'OK we will overwrite the current one'\
        ' we have on file with this movie info'
      )
      FileUtils.rm_rf(rip_path(safe: false))
    else
      Logger.warning(
        "Can't Rip #{Config.configuration.video_name} all ready has been ripped"
      )
    end
  end

  def ask_overwrite_question
    Shell.ask_value_required(
      "Is #{Config.configuration.video_name} of better quality? (Yes|No) ",
      type: TrueClass
    )
  end
end
