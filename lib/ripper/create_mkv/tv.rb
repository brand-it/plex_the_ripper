class CreateMKV
  class TV < Base
    class << self
      def perform
        raise "define peform on #{self.class.name}"
      end
    end

    def delete_extra_episodes
      if episodes.size == Config.configuration.total_episodes
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
          "Failed to delete #{File.join([folder_path, episode])} please destroy file by hand"
        )
        Shell.show_wait_spinner(
          "Failed to delete #{File.join([folder_path, episode])} please destroy file by hand"
        ) do
          File.exist?(File.join([folder_path, episode])) # if file exists keep waiting
        end
      end
    end

    def rename_seasons
      mkv_files.each do |episode|
        season_number = format('%02d', Config.configuration.tv_season)
        episode_number = format('%02d', Config.configuration.episode)
        episode_name = "#{Config.configuration.video_name} "\
                      "- s#{season_number}e#{episode_number}.mkv"
        old_name = File.join([folder_path, episode])
        new_name = File.join([folder_path, episode_name])
        File.rename(old_name, new_name)
        Config.configuration.episode += 1
      end
    end

    private

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

    def tv_titles
      disk_info = get_disk_info
      track_times = parse_title_times(disk_info)
      if Config.configuration.maxlength
        track_times.reject! { |disk| disk[:seconds] > Config.configuration.maxlength }
      end
      @title_numbers = track_times.collect { |x| x[:titles].to_a }.flatten.uniq
    end

    def parse_title_times(disk_info)
      Config.configuration.selected_disc_info.details do |detail|
      end
      track_times = disk_info.select do |disk|
        disk[:integer_two].zero? && disk[:string].match(/[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}/)
      end
      track_times.each do |disk|
        hours, minutes, seconds = disk[:string].split(':').map(&:to_i)
        minutes += (hours * 60)
        seconds += (minutes * 60)
        disk[:seconds] = seconds
      end
      track_times
    end
  end
end
