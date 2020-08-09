# frozen_string_literal: true

# Configuration Information for the ripper application
class Config
  attr_accessor(
    :verbose, :type, :tv_season,
    :video_name, :disc_number, :episode, :selected_disc_info,
    :total_episodes, :include_extras, :maxlength,
    :mkv_from_file, :make_backup_path, :makemkvcon_path,
    :tv_shows_directory_name, :movies_directory_name,
    :the_movie_db_config, :selected_titles, :slack_url,
    :log_level, :ifttt_webhook_key
  )
  attr_reader(:media_directory_path, :the_movie_db_api_key)
  attr_writer(:minlength)

  class << self
    def configuration(reload: false)
      @configuration = nil if reload
      @configuration ||= Config.new
    end
  end

  def initialize
    self.makemkvcon_path = File.join(
      %w[/ Applications MakeMKV.app Contents MacOS makemkvcon]
    )
    self.mkv_from_file = nil
    self.make_backup_path = nil
    self.media_directory_path = File.join(%w[/ Volumes Multimedia])
    self.verbose = false
    self.tv_season = 1
    self.disc_number = 1
    self.type = :movie
    self.video_name = nil
    self.episode = 1
    self.selected_disc_info = nil
    self.total_episodes = 0
    self.minlength = nil
    self.maxlength = nil
    self.include_extras = false
    self.tv_shows_directory_name = 'TV Shows'
    self.movies_directory_name = 'Movies'
    self.the_movie_db_config = TheMovieDbConfig.new
    self.selected_titles = []
    self.slack_url = nil
    self.log_level = 'ERROR'
    self.ifttt_webhook_key = nil
  end

  def videos
    @videos ||= Videos.new
  end

  def log_directory
    @log_directory = File.join([media_directory_path, 'logs'])
  end

  # minlength in seconds
  def minlength
    return @minlength if @minlength
    return 780 if type == :tv

    3600
  end

  def tv_season_to_word
    "Season #{format('%02d', tv_season)}"
  end

  def disc_number_to_word
    "Disc #{format('%02d', disc_number)}"
  end

  def disk_source
    if mkv_from_file.to_s != ''
      "file:#{mkv_from_file}"
    elsif selected_disc_info.dev.to_s != ''
      "dev:#{selected_disc_info.dev}"
    else
      raise 'Failed to resolve the disk source there is a bug in the code'
    end
  end

  def media_directory_path=(value)
    @log_directory = nil
    @media_directory_path = (File.join(File.expand_path(value)) if value)
  end

  def reset!
    self.video_name = nil if Config.configuration.type == :movie
    self.selected_titles = nil
    self.selected_disc_info = nil
  end
end
