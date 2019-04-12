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
        "Name of #{Config.configuration.type} is going to"\
        " be #{Config.configuration.video_name.inspect}"
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
    config.type = Shell.prompt.select('Please select a video type', options)
  end

  def ask_for_video_name
    until video_name_present?
      config.video_name = Shell.ask("What is the Name of this #{config.type}:", type: String)
    end
  end

  def check_against_movie_database
    if Config.configuration.the_movie_db_config.invalid_api_key?
      config.the_movie_db_config.selected_video = nil
    elsif request_videos.size.zero?
      Logger.info("Tried Looking up #{config.video_name} but did not find any")
      config.the_movie_db_config.selected_video = nil
      config.video_name = nil
      @request_videos = nil
      ask_for_video_name
      check_against_movie_database
    elsif request_videos.size == 1
      config.the_movie_db_config.selected_video = request_videos.first
      config.video_name = request_videos.first.name
    else
      select_video_from_results(request_videos)
    end
  end

  def update_runtime
    selected_video = config.the_movie_db_config.selected_video
    runtime = selected_video.runtime if selected_video
    runtime = {}

    # margin = config.type == :movie ? 30 : 5
    margin = 2 # how much of wiggle room we want to give the movie times
    update_minlength(runtime[:min], margin)
    update_maxlength(runtime[:max], margin)

    Logger.info(
      "Updated the min runtime to #{config.minlength.inspect} seconds "\
      "and the max runtime to #{config.maxlength || '∞'} seconds"
    )
  end

  def update_minlength(min, margin)
    return config.minlength = (min - margin) * 60 if min&.positive?

    # We need to change what ever this value was back to nil if it was not nil already
    config.minlength = nil # this will make it use config defaults
  end

  def update_maxlength(max, margin)
    return config.maxlength = (max + margin) * 60 if max.to_i > (config.minlength / 60)

    config.maxlength = nil
  end

  def request_videos
    @request_videos ||= if config.type == :tv
                          TheMovieDB::TV.search(config.video_name)
                        else
                          TheMovieDB::Movie.search(config.video_name)
                        end
  end

  def select_video_from_results(request_videos)
    names = TheMovieDB::Movie.uniq_names(request_videos)

    answer = Shell.prompt.select(
      "Found multiple titles that matched (#{config.video_name}). Pick one from below"
    ) do |menu|
      names.each_with_index do |name, index|
        menu.choice name, index
      end
    end

    config.the_movie_db_config.selected_video = TheMovieDB::TV.find(request_videos[answer].id)
    config.video_name = names[answer]
  end
end
