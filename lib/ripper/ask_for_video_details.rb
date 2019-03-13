# frozen_string_literal: true

class AskForVideoDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  class << self
    def perform
      ask_for_video_details = AskForVideoDetails.new
      ask_for_video_details.update_type
      ask_for_video_details.ask_for_video_name
      ask_for_video_details.check_against_movie_database
      ask_for_video_details.update_runtime
      Logger.info(
        "Name of #{Config.configuration.type} is going to be #{Config.configuration.video_name.inspect}"
      )
    end
  end

  def video_name_present?
    config.video_name.to_s != ''
  end

  def update_type
    options = if config.type == :tv
                %i[tv movie]
              else
                %i[movie tv]
              end
    config.type = TTY::Prompt.new.select('Please select a video type', options)
  end

  def ask_for_video_name
    until video_name_present?
      config.video_name = Shell.ask_value_required(
        "What is the Name of this #{config.type}: ", type: String
      ) do
        Logger.info(config.selected_disc_info.reload.describe) if config.selected_disc_info
      end
    end
  end

  def check_against_movie_database
    return if request_video_names.empty?

    if request_video_names['total_results'] == 1
      config.the_movie_db_config.selected_video = request_video_names['results'].first
      config.video_name = request_video_names['results'].first['name']
    end

    if request_video_names['results'].any?
      select_video_from_results(request_video_names)
    else
      ask_for_a_different_name
      check_against_movie_database
    end
  end

  def update_runtime
    selected_video = config.the_movie_db_config.selected_video
    return if selected_video.nil?

    runtime = TheMovieDB.new.runtime(type: config.type, id: selected_video['id'])
    # margin = config.type == :movie ? 30 : 5
    margin = 2 # how much of wiggle room we want to give the movie times

    config.minlength = (runtime[:min] - margin) * 60 if runtime[:min].positive?
    config.maxlength = (runtime[:max] + margin) * 60 if runtime[:max] > (config.minlength / 60)
    Logger.info(
      "Updated the min runtime to #{config.minlength.inspect} seconds "\
      "and the max runtime to #{config.maxlength || '∞'} seconds"
    )
  end

  def request_video_names
    @request_video_names ||= TheMovieDB.new.search(
      type: config.type, query: config.video_name
    )
  end

  def select_video_from_results(search)
    if search['total_results'].to_i.zero?
      config.the_movie_db_config.selected_video = nil
      config.video_name = nil
      return
    end

    if search['total_results'].to_i == 1
      config.the_movie_db_config.selected_video = search['results'].first
      config.video_name = TheMovieDB.new.uniq_names(search['results']).first
      return
    end

    names = TheMovieDB.new.uniq_names(search['results'])

    answer = TTY::Prompt.new.select(
      "Found multiple titles that matched (#{config.video_name}). Pick one from below"
    ) do |menu|
      names.each_with_index do |name, index|
        menu.choice name, index
      end
    end

    config.the_movie_db_config.selected_video = search['results'][answer]
    config.video_name = names[answer]
  end

  def ask_for_a_different_name
    Logger.warning('When looking up the title in themoviedb.org we could not find TV title')
    config.video_name = nil
    ask_for_video_name
    @request_video_names = nil # clear the local cache because of video_name changing
  end
end
