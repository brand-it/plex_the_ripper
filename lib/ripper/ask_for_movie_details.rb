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
    if config.selected_disc_info.titles.size == 1
      return config.selected_titles = config.selected_disc_info.titles
    end

    config.selected_disc_info.consolidated_details.each do |titles, details|
      Logger.info "Titles: #{titles}"
      Logger.info "  #{details.map(&:name).join(', ')}"
    end
    config.selected_titles = [
      Shell.ask_value_required(
        'Many Titles where found please type in a number:', type: Integer
      )
    ]
  end
end
