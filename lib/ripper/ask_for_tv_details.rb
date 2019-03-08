class AskForTVDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  class << self
    def perform
      return if Config.configuration.type != :tv

      ask_for_tv_details = AskForTVDetails.new
      ask_for_tv_details.check_tv_name
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

  def check_tv_name
    return if request_tv_show_names.nil?

    if request_tv_show_names['total_results'] == 1
      return config.video_id = request_tv_show_names['results'].first['id']
    end

    if request_tv_show_names['results'].any?
      select_tv_show_from_results
    else
      ask_for_a_different_name
      check_tv_name
    end
  end

  def ask_for_a_different_name
    Logger.warning(
      'When looking up the title in themoviedb.org we could not find TV title'
    )
    config.video_name = nil
    AskForVideoDetails.perform
    @tv_shows = nil
  end

  def select_tv_show_from_results
    answer = TTY::Prompt.new.select(
      'Found multiple titles that matched. Pick one from below'
    ) do |menu|
      request_tv_show_names['results'].each_with_index do |result, index|
        menu.choice result['name'], index
      end
    end
    config.the_movie_db_config.selected_video = request_tv_show_names['results'][answer]
    config.video_name = config.the_movie_db_config.selected_video['name']
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
    selections = titles.each_with_object(Hash.new('')) {|i, h| h[i] = ''}
    config.selected_disc_info.details.each do |details|
      next if details.integer_one != 27
      next unless selections.include?[titles.first]
      selections[details.string] = details.titles.first
    end
    config.selected_titles = prompt.multi_select('Select Titles', selections)
  end

  def request_tv_show_names
    @request_tv_show_names ||= config.the_movie_db_config.request(
      'search/tv',
      params: { query: config.video_name }
    )
  end

  def update_runtime
    return if config.the_movie_db_config.selected_video.nil?

    selected_video = config.the_movie_db_config.selected_video
    response = config.the_movie_db_config.request("tv/#{selected_video['id']}")
    config.minlength = (response['episode_run_time'].min - 1) * 60
    config.maxlength = (response['episode_run_time'].max + 1) * 60
  end
end
