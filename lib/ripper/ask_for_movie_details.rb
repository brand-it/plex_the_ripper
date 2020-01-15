# frozen_string_literal: true

class AskForMovieDetails
  include ArrayHelper
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  class << self
    def perform
      return if Config.configuration.type != :movie # these apply for TV as well

      Shell.show_wait_spinner('Loading Disc') do
        !Config.configuration.selected_disc_info.details_loaded?
      end
      ask_for_movie_details = AskForMovieDetails.new
      ask_for_movie_details.ask_for_which_title_if_multiple
    end
  end

  def ask_for_which_title_if_multiple
    titles = config.selected_disc_info.tiles_with_length
    return config.selected_titles = titles.keys if titles.size == 1

    if titles.empty?
      Logger.warning('Could not find a title using min and max. Falling back to using all titles')
      titles = config.selected_disc_info.details
    end
    if titles.nil? || titles.empty?
      raise Plex::Ripper::Abort, 'Could not load titles from Disc the disc might be damaged or the CD drive is having issues'
    end
    answer = Shell.prompt.select(
      'Found multiple titles that matched. Pick one from below', per_page: 25, filter: true
    ) do |menu|
      config.selected_disc_info.friendly_details.each do |detail|
        next unless titles.key?(detail[:title])

        menu.choice detail[:name], detail[:title]
      end
    end

    config.selected_titles = [answer]
  end
end
