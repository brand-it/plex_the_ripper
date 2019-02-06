class AskForTVDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  def self.perform
    return if Config.configuration.type != :tv

    ask_for_tv_details = AskForTVDetails.new
    ask_for_tv_details.ask_for_tv_season
    ask_for_tv_details.ask_for_tv_episode
    ask_for_tv_details.ask_for_disc_number
  end

  private

  def ask_for_tv_season
    config.tv_season = ask_value_required(
      "What season is this (#{tv_season}): ",
      type: Integer, default: config.tv_season
    )
  end

  def ask_for_tv_episode
    config.episode = ask_value_required(
      "What is the start episode (#{episode}): ",
      type: Integer, default: config.episode
    )
  end

  def ask_for_disc_number
    config.disc_number = ask_value_required(
      "What is the disc number for (#{config.disc_number}): ",
      type: Integer, default: config.disc_number
    )
  end
end
