# frozen_string_literal: true

class CreateMKV
  class TV < Base
    class << self
      def perform
        return if Config.configuration.type != :tv

        tv = CreateMKV::TV.new
        tv.start!
        tv.create_mkv
        tv.rename_seasons
        tv.update_config
        tv.finished!
        tv.notify_slack_success
        tv
      end
    end

    def update_config
      Config.configuration.disc_number += 1
    end

    # Don't use this was nice but it was not ideal...
    def delete_extra_episodes
      if mkv_files.size == Config.configuration.total_episodes
        return Logger.success('All right everything looks good')
      end

      if Config.configuration.total_episodes > mkv_files.size
        return Logger.warning(
          'Well this is bummer, it seams there are less episodes than what you where expected.'\
          ' You expected there to be about '\
          "(#{Config.configuration.total_episodes} > #{mkv_files.size}) more episode(s)."
        )
      end
      sort_episodes_magically!
      mkv_files[Config.configuration.total_episodes..mkv_files.size].each do |episode|
        Logger.warning("Deleting #{episode} #{File.size(File.join([directory, episode]))}")
        FileUtils.rm_rf(File.join([directory, episode]))
        next unless File.exist?(File.join([directory, episode]))

        Notification.slack(
          "Issue Deleting File #{episode}",
          "Failed to delete #{File.join([directory, episode])} please destroy file by hand"
        )
        Shell.show_wait_spinner(
          "Failed to delete #{File.join([directory, episode])} please destroy file by hand"
        ) do
          File.exist?(File.join([directory, episode])) # if file exists keep waiting
        end
      end
    end

    def rename_seasons
      mkv_files(reload: true).each_with_index do |episode, index|
        season_number = format('%02d', Config.configuration.tv_season)
        episode_number = format('%02d', Config.configuration.episode + index)
        episode_name = [
          Config.configuration.video_name,
          "s#{season_number}e#{episode_number}",
          episode_name
        ].compact.join(' - ')
        Config.configuration.episode += 1
        old_name = File.join([directory, episode])
        new_name = File.join([directory, "#{episode_name}.mkv"])
        File.rename(old_name, new_name)
      end
    end

    private

    def episode_name
      tv_show_id = Config.configuration.the_movie_db_config.selected_video['id']
      return if tv_show_id.nil?

      season = TheMovieDB.new.season(
        tv_id: tv_show_id, season_number: Config.configuration.tv_season
      )
      return if season.nil?

      episode = season['episodes'].find { |e| e['episode_number'].to_i == Config.configuration.episode }
    end

    def sort_episodes_magically!
      # round to a Gigabyte and sort based off that info. This will also remove the
      # file that is the largest. However it has to be a gigabyte bigger then the other files.
      mkv_files.sort! do |x, y|
        x_file_size = File.size(File.join([directory, x]))
        y_file_size = File.size(File.join([directory, y]))
        if expected_file_size.include?(y_file_size) && !expected_file_size.include?(x_file_size)
          1 # Swap x Possition and y
        elsif expected_file_size.include?(x_file_size) && !expected_file_size.include?(y_file_size)
          -1 # Leave Alone / do nothing
        else
          x <=> y # Sort by name if that file size range does not apply
        end
      end
    end

    def file_size_range # rubocop:disable AbcSize
      files_details[:file_sizes].sort! do |a, b|
        (a - files_details[:mean]).abs <=> (b - files_details[:mean]).abs
      end
      files_details[:file_sizes] = files_details[:file_sizes][
        0..(Config.configuration.total_episodes - 1)
      ]
      Range.new(files_details[:file_sizes].min, files_details[:file_sizes].max)
    end

    def expected_file_size
      return @expected_file_size if @expected_file_size

      if Config.configuration.total_episodes <= 1
        return @expected_file_size = find_largest_file_size
      end

      @expected_file_size = file_size_range
    end

    def find_largest_file_size
      total_gigs = 0
      mkv_files.each do |episode|
        gigs = File.size(File.join([directory, episode]))
        total_gigs = gigs if gigs > total_gigs
      end
      Range.new(total_gigs, total_gigs)
    end

    def files_details
      return @file_details if @file_details

      @file_details = { file_sizes: [], file_size_total: 0, mean: 0 }
      mkv_files.each do |episode|
        @file_details[:file_sizes] << File.size(File.join([directory, episode]))
        @file_details[:file_size_total] += @file_details[:file_sizes].last
      end
      @file_details[:mean] = @file_details[:file_size_total] / @file_details[:file_sizes].length
      @file_details
    end
  end
end
