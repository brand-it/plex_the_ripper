# frozen_string_literal: true

class AskForTVDetails
  attr_accessor :config, :tv_show, :season, :episode

  def initialize
    self.config = Config.configuration
    self.tv_show = config.the_movie_db_config.selected_video
  end

  class << self
    def perform
      return if Config.configuration.type != :tv

      ask_for_tv_details = AskForTVDetails.new
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
    config.tv_season = if tv_show
                         self.season = select_season_from_the_movie_db
                         season.season_number
                       else
                         Shell.ask_value_required(
                           "What season is this (#{config.tv_season}):",
                           type: Integer, default: config.tv_season
                         )
                       end
  end

  def ask_for_tv_episode
    config.episode = if season
                       select_episode_from_the_movie_db.episode_number
                     else
                       Shell.ask_value_required(
                         "What is the episode number (#{config.episode}): ",
                         type: Integer, default: config.episode
                       )
                     end
  end

  def select_season_from_the_movie_db
    Shell.prompt.select('Select a Season') do |menu|
      default = tv_show.seasons.index do |season|
        season['season_number'] == config.tv_season
      end
      menu.default default + 1 if default

      tv_show.seasons.each do |season|
        menu.choice season['name'], TheMovieDb::Season.new(season.merge(tv: tv_show))
      end
    end
  end

  def select_episode_from_the_movie_db
    Shell.prompt.select('Select a Episode') do |menu|
      default = season.episodes.index do |e|
        e['episode_number'] == config.episode
      end
      menu.default default + 1 if default

      season.episodes.each do |episode|
        episode = TheMovieDb::Episode.new(episode)
        ripped = ripped_episodes.any? { |e| e.name == episode.name }
        menu.choice "#{episode.name} #{'(ripped)' if ripped}", episode
      end
    end
  end

  def ask_for_disc_number
    config.disc_number = Shell.ask_value_required(
      "What is the disc number for (#{config.disc_number}): ",
      type: Integer, default: config.disc_number
    )
  end

  def try_to_get_titles_using_closest_time
    times = config.selected_disc_info.title_seconds.values.sort
    Config.configuration.maxlength = times.group_by { |x| x <=> Config.configuration.maxlength }[-1].last
    minlength = times.group_by { |x| x <=> Config.configuration.minlength }[-1].reject { |x| x == Config.configuration.maxlength }
    Config.configuration.minlength = minlength.last
    Logger.warning("Failed to find titles changing the min to #{Config.configuration.minlength} and max to #{Config.configuration.maxlength}")
    config.selected_disc_info.tiles_with_length
  end

  def ripped_episodes
    return @ripped_episodes if @ripped_episodes.to_a.any?

    videos = Config.configuration.videos
    tv_show = videos.find_tv_show(Config.configuration.video_name)
    return [] if tv_show.nil?

    season = tv_show.find_season(Config.configuration.tv_season)
    return [] if season.nil?

    @ripped_episodes ||= season.episodes
  end

  def ask_user_to_select_titles(show_all: false)
    titles = config.selected_disc_info.tiles_with_length
    if config.selected_disc_info.details.empty?
      raise Plex::Ripper::Abort, 'This disc has no titles that is strange... I have to give up'
    end

    titles = try_to_get_titles_using_closest_time if titles.size <= 1
    titles = config.selected_disc_info.details if titles.size <= 1

    titles = TTY::Prompt.new.multi_select(
      'Found a few options. Select the episodes on this disc', echo: false
    ) do |menu|
      config.selected_disc_info.friendly_details.each do |detail|
        menu.choice detail[:name], detail[:title].to_i if show_all || titles.key?(detail[:title])
      end

      menu.choice('Show All Titles', true) unless show_all
    end

    if titles.empty?
      ask_user_to_select_titles
    elsif titles.include?(true)
      ask_user_to_select_titles(show_all: true)
    else
      config.selected_titles = titles
    end
  end
end
