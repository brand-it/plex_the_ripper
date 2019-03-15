# frozen_string_literal: true

class AskForTVDetails
  attr_accessor :config, :tv_show, :season, :episode

  def initialize
    self.config = Config.configuration
    selected_video = config.the_movie_db_config.selected_video
    self.tv_show = TheMovieDB.new.video(id: selected_video['id'], type: config.type) if selected_video
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
                         answer = TTY::Prompt.new.select('Select a season') do |menu|
                           default = tv_show['seasons'].index { |e| e['season_number'] == config.tv_season }
                           menu.default default + 1 if default

                           tv_show['seasons'].each do |season|
                             menu.choice season['name'], season['season_number']
                           end
                         end
                         self.season = TheMovieDB.new.season(tv_id: tv_show['id'], season_number: config.tv_season)
                         answer
                       else
                         Shell.ask_value_required(
                           "What season is this (#{config.tv_season}):",
                           type: Integer, default: config.tv_season
                         )
    end
  end

  def ask_for_tv_episode
    config.episode = if season
                       TTY::Prompt.new.select('Select a Episode') do |menu|
                         default = season['episodes'].index { |e| e['episode_number'] == config.episode }
                         menu.default default + 1 if default

                         season['episodes'].each do |episode|
                           menu.choice episode['name'], episode['episode_number']
                         end
                       end
                     else
                       Shell.ask_value_required(
                         "What is the episode number (#{config.episode}): ",
                         type: Integer, default: config.episode
                       )
    end
  end

  def ask_for_disc_number
    config.disc_number = Shell.ask_value_required(
      "What is the disc number for (#{config.disc_number}): ",
      type: Integer, default: config.disc_number
    )
  end

  def ask_user_to_select_titles
    titles = config.selected_disc_info.tiles_with_length

    if titles.empty?
      Logger.warning('Could not find a title using min and max. Falling back to using all titles')
      titles = config.selected_disc_info.titles
    end
    config.selected_titles = TTY::Prompt.new.multi_select(
      'Found a few options. Select the episodes on this disc'
    ) do |menu|
      config.selected_disc_info.friendly_details.each do |detail|
        next unless titles.key?(detail[:title])

        menu.choice detail[:name], detail[:title]
      end
    end
  end
end
