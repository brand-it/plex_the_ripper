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

  def check_movie_name
    return if request_movie_names.nil?

    if request_movie_names['total_results'] == 1
      config.the_movie_db_config.selected_video = search['results'].first
      config.video_name = search['results'].first['name']
    end

    if request_movie_names['results'].any?
      select_movie_from_results(request_movie_names)
    else
      ask_for_a_different_name
      check_tv_name
    end
  end

  def ask_for_which_title_if_multiple
    titles = config.selected_disc_info.tiles_with_length
    return config.selected_titles = titles.keys if titles.size == 1

    if titles.empty?
      Logger.warning('Could not find a title using min and max. Falling back to using all titles')
      titles = config.selected_disc_info.titles
    end

    answer = TTY::Prompt.new.select(
      'Found multiple titles that matched. Pick one from below'
    ) do |menu|
      config.selected_disc_info.friendly_details.each do |detail|
        next unless titles.key?(detail[:title])

        menu.choice detail[:name], detail[:title]
      end
    end

    config.selected_titles = [answer]
  end
end
