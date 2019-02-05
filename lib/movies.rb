
class Movies
  include BashHelper
  attr_accessor :server_movies, :local_movies
  attr_reader :total_uploaded_disks

  def initialize
    self.local_movies = {}
    self.server_movies = {}
  end

  def movie_present?(name:, scope: :all)
    if Config.configuration.type == :tv
      season = Config.configuration.tv_season_to_word
      disc = Config.configuration.disc_number_to_word
    end
    find_movie(name: name, season: season, disc: disc, scope: scope) != nil
  end

  def find_movie(name:, season: nil, disc: nil, scope: :all)
    name = name.downcase
    movie = if scope == :local
              local_movies[name]
            elsif scope == :server
              server_movies[name]
            else
              local_movies[name] || server_movies[name]
            end
    return movie if movie.nil? || season.nil?
    return movie.find { |m| m == disc } if movie.is_a?(Array)
    season = movie[season]
    return season if season.nil? || disc.nil?
    season[disc]
  end

  def update_movies
    Logger.info("Checking local storage path:#{Config.configuration.file_path}")
    update_local_movies
  end

  def present?(movie_name)
    movie_name = movie_name.downcase
    local_movies.include?(movie_name) || server_movies.include?(movie_name)
  end

  private

  def update_local_movies
    mkv_file_paths = parse_ls(Config.configuration.file_path, remote: false)
    self.local_movies = { total_disks: 0 }
    mkv_file_paths.map { |mkv_file_path| details(mkv_file_path, local_movies) }
  end

  # def log_changes(old_movies, new_movies, type)
  #   movies_removed = old_movies - new_movies
  #   movies_added = new_movies - old_movies
  #   if movies_removed.any?
  #     Logger.info("Removed #{type} (#{movies_removed.size}) #{movies_removed.join(', ')}")
  #   end
  #   return unless movies_added.any?
  #   Logger.info("Added #{type} (#{movies_added.size}) #{movies_added.join(', ')}")
  # end

  def details(mkv_file_path, storage)
    type = find_file_type(mkv_file_path)
    if type == :tv
      tv_details = parse_tv_details(mkv_file_path)
      Logger.debug(
        "adding tv show #{tv_details[:title]}/#{tv_details[:season]}/#{tv_details[:disk]}/#{tv_details[:mkv]}"
      )
      storage[tv_details[:title]] ||= {}
      storage[tv_details[:title]][tv_details[:season]] ||= {}
      if storage[tv_details[:title]][tv_details[:season]][tv_details[:disk]].nil?
        storage[:total_disks] += 1
        storage[tv_details[:title]][tv_details[:season]][tv_details[:disk]] = []
      end
      storage[tv_details[:title]][tv_details[:season]][tv_details[:disk]] ||= []
      storage[tv_details[:title]][tv_details[:season]][tv_details[:disk]] << tv_details[:mkv]
    elsif type == :movie
      movie_details = parse_movie_details(mkv_file_path)
      return if movie_details.size.zero?
      Logger.debug("adding movie #{movie_details[:title]}/#{movie_details[:mkv]}")
      if storage[movie_details[:title]].nil?
        storage[:total_disks] += 1
        storage[movie_details[:title]] = []
      end
      storage[movie_details[:title]] << movie_details[:mkv]
    else
      Logger.debug("Could not figure out type for #{mkv_file_path.inspect}")
    end
  end

  def find_file_type(mkv_file_path)
    return :tv if mkv_file_path.include?('TV Shows')
    return :movie if mkv_file_path.include?('Movies')
    :unknown
  end

  def parse_tv_details(mkv_file_path)
    index = mkv_file_path.split('/').find_index { |x| x == 'TV Shows' }
    details = mkv_file_path.split('/').reject.with_index { |_t, x| x <= index }
    return {} if details.size > 4
    {
      title: details[0].downcase,
      season: details[1],
      disk: details[2],
      mkv: details[3]
    }
  end

  def parse_movie_details(mkv_file_path)
    index = mkv_file_path.split('/').find_index { |x| x == 'Movies' }
    details = mkv_file_path.split('/').reject.with_index { |_t, x| x <= index }
    return {} if details.size > 2
    {
      title: details[0].downcase,
      mkv: details[1]
    }
  end

  def parse_ls(path, remote:)
    ls_command = "find #{Shellwords.escape(path)} -name '*.mkv'"
    command = if remote
                "ssh #{Config.configuration.scp_info} '#{ls_command}'"
              else
                ls_command
              end
    response = capture3(command)
    Logger.debug(response.stdout_str)
    return [] unless response.status.success?
    results = response.stdout_str.split("\n").compact.uniq
    results.reject! do |result|
      result == '' || result.include?('Plex Versions') || result.include?('.@__thumb')
    end
    results.map { |x| x.gsub(path + '/', '') }
  end
end
