class AskForMovieDetails
  include ArrayHelper
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end
  class << self
    def perform(loading_details_thread)
      # return if Config.configuration.type != :movie these apply for TV as well

      ask_for_movie_details = AskForMovieDetails.new
      ask_for_movie_details.ask_for_movie_name
      ask_for_movie_details.puts_movie_name
      Shell.show_wait_spinner('waiting to for disc details') do
        loading_details_thread.alive?
      end
      ask_for_movie_details.ask_for_which_title_if_multiple
    end
  end

  def ask_for_which_title_if_multiple
    if config.selected_disc_info.titles.size == 1
      return config.movie_title = config.selected_disc_info.titles
    end

    config.selected_disc_info.consolidated_details.each do |titles, details|
      Logger.info "Titles: #{titles}"
      Logger.info "  #{details.map(&:name).join(', ')}"
    end
    config.movie_title = Shell.ask_value_required(
      'Many Titles where found please type in a number: ', type: Integer
    )
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
      Logger.info(config.selected_disc_info.reload.describe) if config.selected_disc_info
    end
  end
end
