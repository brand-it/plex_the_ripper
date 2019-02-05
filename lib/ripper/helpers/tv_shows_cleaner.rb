module TVShowsCleaner
  include BashHelper
  include HumanizerHelper

  def rename_seasons(folder_path)
    return unless Config.configuration.type == :tv

    episodes_list = episodes(folder_path)
    episodes_list.each do |episode|
      season = format('%02d', Config.configuration.tv_season)
      episode_number = format('%02d', Config.configuration.episode)
      episode_name = "#{Config.configuration.movie_name} "\
                     "- s#{season}e#{episode_number}.mkv"
      old_name = File.join([folder_path, episode])
      new_name = File.join([folder_path, episode_name])
      File.rename(old_name, new_name)
      Config.configuration.episode += 1
    end
  end

  def ask_if_total_number_of_episodes
    return if Config.configuration.type != :tv

    Config.configuration.total_episodes = ask_value_required('How many episodes are should there be? ', type: Integer)
  end

  def delete_extra_episodes(folder_path)
    return if Config.configuration.type != :tv

    episodes_list = episodes(folder_path)
    if episodes_list.size == Config.configuration.total_episodes
      return Logger.success('All right everything looks good')
    end

    if Config.configuration.total_episodes > episodes_list.size
      return Logger.warning(
        'Well this is bummer, it seams there are less episodes than what you where expected.'\
        " You expected there to be about (#{Config.configuration.total_episodes} > #{episodes_list.size}) more episode(s)."
      )
    end
    sort_episodes_magically!(folder_path, episodes_list)
    episodes_list[Config.configuration.total_episodes..episodes_list.size].each do |episode|
      Logger.warning("Deleting #{episode} #{File.size(File.join([folder_path, episode]))}")
      FileUtils.rm_rf(File.join([folder_path, episode]))
      next unless File.exist?(File.join([folder_path, episode]))

      Notification.slack(
        "Issue Deleting File #{episode}",
        "Failed to delete #{File.join([folder_path, episode])} please destroy file by hand"
      )
      show_wait_spinner(
        "Failed to delete #{File.join([folder_path, episode])} please destroy file by hand"
      ) do
        File.exist?(File.join([folder_path, episode])) # if file exists keep waiting
      end
    end
  end

  private

  def episodes(folder_path)
    Dir.entries(folder_path).select do |episode|
      File.extname(episode) == '.mkv'
    end
  end

  def sort_episodes_magically!(folder_path, episodes_list)
    # round to a Gigabyte and sort based off that info. This will also remove the
    # file that is the largest. However it has to be a gigabyte bigger then the other files.
    file_size_range = expected_file_size(folder_path, episodes_list)
    episodes_list.sort! do |x, y|
      x_file_size = File.size(File.join([folder_path, x]))
      y_file_size = File.size(File.join([folder_path, y]))
      if file_size_range.include?(y_file_size) && !file_size_range.include?(x_file_size)
        1 # Swap x Possition and y
      elsif file_size_range.include?(x_file_size) && !file_size_range.include?(y_file_size)
        -1 # Leave Alone / do nothing
      else
        x <=> y # Sort by name if that file size range does not apply
      end
    end
  end

  def file_size_range(folder_path, episodes_list) # rubocop:disable Metrics/AbcSize
    details = files_details(folder_path, episodes_list)
    details[:file_sizes].sort! do |a, b|
      (a - details[:mean]).abs <=> (b - details[:mean]).abs
    end
    details[:file_sizes] = details[:file_sizes][0..(Config.configuration.total_episodes - 1)]
    Range.new(details[:file_sizes].min, details[:file_sizes].max)
  end

  def expected_file_size(folder_path, episodes_list)
    if Config.configuration.total_episodes <= 1
      return find_largest_file_size(folder_path, episodes_list)
    end

    file_size_range(folder_path, episodes_list)
  end

  def find_largest_file_size(folder_path, episodes_list)
    total_gigs = 0
    episodes_list.each do |episode|
      gigs = File.size(File.join([folder_path, episode]))
      total_gigs = gigs if gigs > total_gigs
    end
    Range.new(total_gigs, total_gigs)
  end

  def files_details(folder_path, episodes_list)
    details = { file_sizes: [], file_size_total: 0, mean: 0 }
    episodes_list.each do |episode|
      details[:file_sizes] << File.size(File.join([folder_path, episode]))
      details[:file_size_total] += details[:file_sizes].last
    end
    details[:mean] = details[:file_size_total] / details[:file_sizes].length
    details
  end
end
