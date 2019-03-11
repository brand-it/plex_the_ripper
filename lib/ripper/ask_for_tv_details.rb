# frozen_string_literal: true

class AskForTVDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  class << self
    def perform
      return if Config.configuration.type != :tv

      ask_for_tv_details = AskForTVDetails.new
      ask_for_tv_details.update_runtime
      ask_for_tv_details.ask_for_tv_season
      ask_for_tv_details.ask_for_disc_number
      ask_for_tv_details.ask_for_tv_episode
      Shell.show_wait_spinner('Loading Disc') do
        !Config.configuration.selected_disc_info.details_loaded?
      end
      ask_for_tv_details.ask_user_to_select_titles
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

  def ask_user_to_select_titles
    titles = config.selected_disc_info.tiles_with_length
    selections = titles.each_with_object(Hash.new('')) { |i, h| h[i] = '' }
    config.selected_disc_info.details.each do |details|
      next if details.integer_one != 27
      next unless selections.include?[titles.first]

      selections[details.string] = details.titles.first
    end
    config.selected_titles = prompt.multi_select('Select Titles', selections)
  end

  def request_tv_show_names
    @request_tv_show_names ||= TheMovieDB.new.search(
      type: 'tv', query: config.video_name
    )
  end
end
