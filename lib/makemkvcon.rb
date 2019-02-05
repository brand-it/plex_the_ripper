class MakeMKVCon
  include BashHelper
  include TimeHelper
  include TVShowsCleaner
  include HumanizerHelper

  attr_reader :run_time, :title_numbers

  def initialize
    @rip_path = if Config.configuration.type == :tv
                  [
                    Config.configuration.file_path,
                    'TV Shows',
                    Config.configuration.movie_name,
                    Config.configuration.tv_season_to_word,
                    Config.configuration.disc_number_to_word
                  ]
                else
                  [
                    Config.configuration.file_path,
                    'Movies',
                    Config.configuration.movie_name
                  ]
                end
    @run_time = 0
  end

  def create_backup
    execute_system!
  end

  def create_mkv
    ask_if_total_number_of_episodes
    if already_ripped?
      yes = ask_value_required(
        "Is #{Config.configuration.movie_name} of better quality? (Yes|No) ",
        type: TrueClass
      )
      if yes
        Logger.info('OK we will overwrite the current one we have on file with this movie info')
        FileUtils.rm_rf(rip_path(safe: false))
      else
        Logger.warning(
          "Can't Rip #{Config.configuration.movie_name} all ready has been ripped"
        )
        return
      end
    end
    check_for_multiple_movies
    resolve_tv_data
    started_at = Time.now
    title_numbers.each do |title_number|
      break unless success?

      execute(title_number)
    end
    copy_extras
    @run_time = Time.now - started_at
    done
  end

  def copy_extras
    return if Config.configuration.include_extras == false

    all_titles = get_all_titles
    all_titles.each do |title_number|
      next if title_numbers.include?(title_number)

      execute(title_number, sub_directory: 'Behind The Scenes')
    end
  end

  def execute(title_number, sub_directory: nil)
    command = command(title_number: title_number, sub_directory: sub_directory)
    Logger.debug(command)
    status = execute_system!(command)
    if status.success? && Dir[rip_path + '/*'].any?
      @success = true
    else
      failed(title_number)
    end
  end

  def success?
    @success != false
  end

  def delete_rip_path!
    Logger.debug("delete_rip_path! #{rip_path(safe: false)}")
    FileUtils.rm_rf(rip_path(safe: false))
  end

  def rip_path(safe: true, create_directory: false, sub_directory: nil)
    path = sub_directory ? @rip_path + [sub_directory] : @rip_path
    Logger.debug(path)
    create_path(path) if create_directory
    if safe
      Shellwords.escape(File.join(path))
    else
      File.join(path)
    end
  end

  def size
    size = 0
    mkv_files.each do |file|
      path = File.join([rip_path(safe: false), file])
      size += File.size(path)
    end
    size
  end

  private

  def mkv_files
    Dir.entries(rip_path(safe: false)).reject do |movie|
      movie == '..' || movie == '.'
    end
  end

  def rename_movies
    return unless Config.configuration.type == :movie

    movies = mkv_files
    movies.sort!
    movies.each_with_index do |movie, index|
      number = format('%02d', index)
      movie_name = if movies.size > 1
                     "#{Config.configuration.movie_name} - #{number}.mkv"
                   else
                     "#{Config.configuration.movie_name}.mkv"
                   end
      old_name = File.join([rip_path(safe: false), movie])
      new_name = File.join([rip_path(safe: false), movie_name])
      File.rename(old_name, new_name)
    end
  end

  def create_path(path)
    path = File.join(path)
    return if File.exist?(path)

    Logger.warning("Creating file path #{path}")
    FileUtils.mkdir_p(path)
  end

  def already_ripped?
    Config.configuration.movies.movie_present?(
      name: Config.configuration.movie_name
    )
  end

  def command(title_number: nil, sub_directory: nil)
    [
      Config.configuration.makemkvcon_path,
      'mkv',
      disk_source,
      (title_number || 'all'),
      rip_path(create_directory: true, sub_directory: sub_directory),
      "--minlength=#{Config.configuration.minlength}",
      '--progress=-same',
      '--noscan',
      '--robot',
      '--profile="FLAC"'
    ].join(' ')
  end

  def backup_command
    [
      Config.configuration.makemkvcon_path,
      'backup',
      disk_source,
      Config.configuration.make_backup_path
    ].join(' ')
  end

  def done
    return unless success?

    delete_extra_episodes(rip_path(safe: false))
    rename_seasons(rip_path(safe: false))
    rename_movies
    Notification.slack(
      "Finished ripping #{humanize_disk_info}",
      "It took a total of #{human_seconds(run_time)} to rip #{Config.configuration.movie_name}",
      message_color: 'green'
    )
  end

  def failed(title_number)
    Logger.error(
      "Could not rip file #{Config.configuration.movie_name} #{command(title_number: title_number)}"
    )
    Notification.slack(
      "Failed ripping #{humanize_disk_info}",
      "There was a issue making a copy of #{Config.configuration.movie_name}",
      message_color: 'red'
    )
    @success = false
  end

  def resolve_tv_data
    return if Config.configuration.type != :tv

    disk_info = get_disk_info
    track_times = parse_title_times(disk_info)
    if Config.configuration.maxlength
      track_times.reject! { |disk| disk[:seconds] > Config.configuration.maxlength }
    end
    @title_numbers = track_times.collect { |x| x[:titles].to_a }.flatten.uniq
  end

  def get_disk_info
    get_disk_info_command = [
      Config.configuration.makemkvcon_path,
      'info',
      disk_source,
      "--minlength=#{Config.configuration.minlength}",
      '-r'
    ].join(' ')
    Logger.info(
      "Inspecting #{disk_source} with min length #{Config.configuration.minlength} seconds"
    )
    parse_disk_info_string(system!(get_disk_info_command).stdout_str)
  end

  def check_for_multiple_movies
    return if Config.configuration.type == :tv

    Config.configuration.movies.update_movies
    all_titles = get_all_titles
    if all_titles.size == 1
      @title_numbers = [all_titles.first]
    elsif all_titles.size > 1
      Logger.warning('There was more then one movie found. Please Select one of the title above')
      @title_numbers = [ask_value_required(
        'Which one do you want to keep?(Title Number) ',
        type: Integer
      )]
    else
      Logger.warning 'Well this sucks I got zero titles for this disk'
      Logger.warning all_titles.inspect
      Logger.warning get_disk_info.inspect
    end
  end

  def get_all_titles
    disk_info = get_disk_info
    all_titles = Set[]
    groups = disk_info.group_by { |x| x[:titles].to_a }
    groups.each do |group, hash_details|
      all_titles.merge!(group)
      Logger.info "Title: #{group}"
      hash_details.each do |hash|
        Logger.info "  #{hash[:string]}"
      end
    end
    all_titles
  end

  def parse_title_times(disk_info)
    track_times = disk_info.select do |disk|
      disk[:integer_two] == 0 && disk[:string].match(/[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}/)
    end
    track_times.each do |disk|
      hours, minutes, seconds = disk[:string].split(':').map(&:to_i)
      minutes += (hours * 60)
      seconds += (minutes * 60)
      disk[:seconds] = seconds
    end
    track_times
  end

  def parse_disk_info_string(disk_info_string)
    lines = disk_info_string.split("\n")
    groups = []
    lines.each do |line|
      match = line.delete('"').match(/(\A.*?):(.*)/)
      values = match[2].split(',')
      case match[1]
      when 'TINFO'
        dup_group = groups.find do |group|
          group[:string] == values[3] && group[:integer_one] == values[1].to_i
        end
        if dup_group
          dup_group[:titles].add(values[0].to_i)
        else
          groups << {
            integer_one: values[1].to_i,
            integer_two: values[2].to_i,
            string: values[3].to_s,
            titles: Set[values[0].to_i]
          }
        end
      when 'SINFO'
        dup_group = groups.find do |group|
          group[:string] == values[4].to_s
        end
        if dup_group
          dup_group[:titles].add(values[0].to_i)
        else
          groups << {
            integer_one: values[2].to_i,
            integer_two: values[3].to_i,
            string: values[4].to_s,
            titles: Set[values[0].to_i]
          }
        end
      end
    end
    raise 'No disk information found' if groups.size.zero?

    groups
  end

  def disk_source
    if Config.configuration.mkv_from_file.to_s != ''
      "file:#{Config.configuration.mkv_from_file}"
    elsif Config.configuration.selected_disc_info.dev.to_s != ''
      "dev:#{Config.configuration.selected_disc_info.dev}"
    else
      raise 'Failed to resolve the disk source there is a bug in the code'
    end
  end

  def execute_system!(_command)
    semaphore = Mutex.new
    progressbar = ProgressBar.create(format: '%e |%b>>%i| %p%% %t')
    current_progress = 0
    current_title = nil
    max = 0
    type = ''
    values = ''

    Open3.popen2e({}, command(title_number: title_number, sub_directory: sub_directory)) do |stdin, std_out_err, wait_thr|
      stdin.close
      Thread.new do
        while raw_line = std_out_err.gets # rubocop:disable Lint/AssignmentInCondition
          Logger.debug(raw_line.strip)
          semaphore.synchronize do
            type, values = raw_line.strip.split(':')
            if type == 'PRGV'
              _current, progress, max = values.split(',').map(&:to_i)
              progressbar.total = max if max != progressbar.total
              progressbar.progress += (progress - current_progress)
              current_progress = progress
            elsif type == 'PRGC' && current_title != values.split(',').last.strip
              current_title = values.split(',').last.strip
              progressbar.finish
              progressbar.reset
              progressbar.title = current_title
              progressbar.start
            end
          end
        end
        progressbar.finish
      end.join
      wait_thr.value
    end
  end
end
