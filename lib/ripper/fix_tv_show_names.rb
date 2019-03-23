# frozen_string_literal: true

class FixTVShowNames
  class << self
    def perform
      Config.configuration.videos.tv_shows.each do |tv_show|
        ask_for_tv_details(tv_show)
        tv_show.seasons.each do |season|
          season.episodes.each do |episode|
            rename(tv_show, season, episode)
          end
        end

        rename_directory(tv_show)
      end
    end

    def rename_directory(tv_show)
      old_directory = tv_show.directory
      new_directory = tv_show.directory.gsub(tv_show.title, Config.configuration.video_name)
      return if old_directory == new_directory

      Logger.info("Renaming Directory #{old_directory} #{new_directory}")
      File.rename(old_directory, new_directory)
    end

    def rename(tv_show, season, episode)
      return if episode.name == tv_show.title

      name = request_episode_name(season_number: season.number, episode_number: episode.number)
      season_number = format('%02d', season.number)
      episode_number = format('%02d', episode.number)
      episode_name = if name
                       "#{tv_show.title} - s#{season_number}e#{episode_number} - #{name}.mkv"
                     else
                       "#{tv_show.title} - s#{season_number}e#{episode_number}.mkv"
                     end
      new_name = File.join([File.dirname(episode.file_path), episode_name])
      Logger.info("Renaming #{episode.file_path} => #{new_name}")
      File.rename(episode.file_path, new_name)
    end

    def request_episode_name(season_number:, episode_number:)
      selected_video = Config.configuration.the_movie_db_config.selected_video
      return if selected_video.nil?

      result = TheMovieDB.new.episode(
        tv_id: selected_video['id'], season_number: season_number, episode_number: episode_number
      )
      return if result.nil?

      result['name']
    end

    def ask_for_tv_details(tv_show)
      search = TheMovieDB.new.search(type: 'tv', query: tv_show.title)
      if search['total_results'].to_i.zero?
        Config.configuration.the_movie_db_config.selected_video = nil
        Config.configuration.video_name = tv_show.title
        return
      end

      if search['total_results'] == 1
        Config.configuration.the_movie_db_config.selected_video = search['results'].first
        Config.configuration.video_name = search['results'].first['name']
      end

      names = TheMovieDB.new.uniq_names(search['results'])

      answer = TTY::Prompt.new.select(
        "Found multiple titles that matched (#{tv_show.title}). Pick one from below"
      ) do |menu|
        names.each_with_index do |name, index|
          menu.choice name, index
        end
      end

      Config.configuration.the_movie_db_config.selected_video = search['results'][answer]
      Config.configuration.video_name = names[answer]
    end
  end
end
