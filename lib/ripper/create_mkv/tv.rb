# frozen_string_literal: true

class CreateMKV
  class TV < Base
    class << self
      def perform
        return if Config.configuration.type != :tv

        tv = CreateMKV::TV.new
        tv.start!
        tv.create_mkv
        tv.rename_episodes
        tv.update_config
        tv.finished!
        tv.notify_slack_success
        tv
      end
    end

    def update_config
      Config.configuration.disc_number += 1
    end

    def rename_episodes
      mkv_files(reload: true).each_with_index do |episode, index|
        season_number = format('%02d', Config.configuration.tv_season)
        episode_number = format('%02d', Config.configuration.episode + index)
        episode_name = [
          Config.configuration.video_name,
          "s#{season_number}e#{episode_number}",
          episode_name(Config.configuration.episode + index)
        ].compact.join(' - ')
        Config.configuration.episode += 1
        old_name = File.join([directory, episode])
        new_name = File.join([directory, "#{episode_name}.mkv"])
        File.rename(old_name, new_name)
      end
    end

    private

    def episode_name(episode_number)
      tv_show = Config.configuration.the_movie_db_config.selected_video
      return if tv_show.nil?

      season = tv_show.find_season_by_number(Config.configuration.tv_season)
      return if season.nil?

      season.find_episode_by_number(episode_number)&.name
    end
  end
end
