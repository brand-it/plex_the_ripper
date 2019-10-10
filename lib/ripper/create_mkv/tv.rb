# frozen_string_literal: true

class CreateMKV
  class TV < Base
    class << self
      def perform
        return if Config.configuration.type != :tv

        tv = CreateMKV::TV.new
        tv.start!
        Logger.info("Starting to create TV: #{tv.send(:new_name)}")
        tv.create_mkv
        tv.update_config
        tv
      end
    end

    def update_config
      Config.configuration.disc_number += 1
    end

    def rename_mkv(mkv_file_name:, index:)
      old_name = File.join([directory, mkv_file_name])
      Logger.info("Renaming file: '#{old_name}' => '#{new_name}'")
      File.rename(old_name, new_name)
      Config.configuration.episode += 1
    end

    private

    def new_name
      season_number = format('%02d', Config.configuration.tv_season)
      episode_number = format('%02d', Config.configuration.episode)
      episode_name = [
        Config.configuration.video_name,
        "s#{season_number}e#{episode_number}",
        episode_name(Config.configuration.episode)
      ].compact.join(' - ')
      File.join([directory, "#{episode_name}.mkv"])
    end

    def episode_name(episode_number)
      tv_show = Config.configuration.the_movie_db_config.selected_video
      return if tv_show.nil?

      season = tv_show.find_season_by_number(Config.configuration.tv_season)
      return if season.nil?

      season.find_episode_by_number(episode_number)&.name
    end
  end
end
