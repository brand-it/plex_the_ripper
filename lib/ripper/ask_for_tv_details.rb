class AskForTVDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  class << self
    def perform(loading_details_thread)
      return if Config.configuration.type != :tv

      ask_for_tv_details = AskForTVDetails.new
      ask_for_tv_details.ask_for_tv_season
      ask_for_tv_details.ask_for_tv_episode
      ask_for_tv_details.ask_for_disc_number
      Shell.show_wait_spinner('waiting to for disc details') do
        loading_details_thread.alive?
      end
      ask_for_tv_details.ask_for_total_number_of_episodes
    end
  end

  def ask_for_tv_season
    config.tv_season = Shell.ask_value_required(
      "What season is this (#{config.tv_season}): ",
      type: Integer, default: config.tv_season
    )
  end

  def ask_for_tv_episode
    config.episode = Shell.ask_value_required(
      "What is the start episode (#{config.episode}): ",
      type: Integer, default: config.episode
    )
  end

  def ask_for_disc_number
    config.disc_number = Shell.ask_value_required(
      "What is the disc number for (#{config.disc_number}): ",
      type: Integer, default: config.disc_number
    )
  end

  def ask_for_total_number_of_episodes
    config.total_episodes = Shell.ask_value_required(
      "How many episodes are should there be for #{config.video_name}"\
      " (#{config.selected_disc_info.titles.size})? ",
      type: Integer, default: config.selected_disc_info.titles.size
    )
  end
end
