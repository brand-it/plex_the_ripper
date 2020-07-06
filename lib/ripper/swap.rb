# frozen_string_literal: true

class Swap
  attr_accessor :config, :tv_show, :season, :episode, :swap_season, :swap_episode

  class << self
    def perform
      swap = Swap.new
      swap.tv_show = swap.find_tv_show
      swap.season = swap.find_season
      swap.episode = swap.find_episode(swap.season)
      swap.swap_season = swap.find_season
      swap.swap_episode = swap.find_episode(swap.swap_season)
      swap.make_it_so
    end
  end

  def initialize
    @config = Config.configuration
  end

  def make_it_so
    file_path_a = episode.file_path
    file_path_b = swap_episode.file_path
    directory_name_a = File.dirname(file_path_a)

    Logger.info("Swapping #{file_path_a} with #{file_path_b}")
    return unless Shell.prompt.yes?('Are you sure you want to swap those two files?')

    File.rename(file_path_a, File.join([directory_name_a, 'tmp_name_a.mkv']))
    Logger.info("Moving #{file_path_b} to #{file_path_a}")
    FileUtils.mv(file_path_b, file_path_a)
    Logger.info("Moving #{File.join([directory_name_a, 'tmp_name_a.mkv'])} to #{file_path_b}")
    FileUtils.mv(File.join([directory_name_a, 'tmp_name_a.mkv']), file_path_b)
  end

  def find_tv_show
    raise(Plex::Ripper::Abort, 'Could not find any TV shows to swap') if config.videos.tv_shows.empty?

    Shell.prompt.select('Choose a tv show?', tv_shows_for_select, filter: true)
  end

  def find_season
    check_season_valid!
    return tv_show.seasons.first if tv_show.seasons.size == 1

    Shell.prompt.select('Choose a season?', seasons_for_select, filter: true)
  end

  def find_episode(selected_season)
    return selected_season.episodes.first if selected_season.episodes.size == 1

    Shell.prompt.select(
      'Choose a episode you want to swap?', episodes_for_select(selected_season), filter: true
    )
  end

  private

  def tv_shows_for_select
    config.videos.tv_shows.each_with_object({}) { |video, hash| hash[video.title] = video }
  end

  def seasons_for_select
    tv_show.seasons.each_with_object({}) { |season, hash| hash["Season #{season.number}"] = season }
  end

  def episodes_for_select(selected_season)
    selected_season.episodes.each_with_object({}) do |episode, hash|
      hash["#{episode.name} (#{episode.number}) "] = episode
    end
  end

  def check_season_valid!
    raise Plex::Ripper::Termimate, 'TV SHOW IS MISSING PANIC SUPER PANIC' if tv_show.nil?
    return if tv_show.seasons.size >= 1

    raise(Plex::Ripper::Abort, "There are no seasons for #{tv_show.title}")
  end
end
