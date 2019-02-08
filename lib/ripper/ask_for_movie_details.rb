class AskForMovieDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end
  class << self
    def perform
      # return if Config.configuration.type != :movie these apply for TV as well

      ask_for_movie_details = AskForMovieDetails.new
      ask_for_movie_details.ask_for_movie_name
      ask_for_movie_details.puts_movie_name
    end
  end

  def puts_movie_name
    Logger.info(
      "Name of #{config.type} is going to be #{config.video_name.inspect}"
    )
  end

  def movie_name_present?
    config.video_name.to_s != ''
  end

  def ask_for_movie_name
    return if movie_name_present?

    config.video_name = Shell.ask_value_required(
      "What is the Name of this #{config.type}: ", type: String
    ) do
      if config.selected_disc_info
        Logger.info(config.selected_disc_info.reload.describe)
      end
    end
  end
end
