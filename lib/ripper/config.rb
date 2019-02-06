# Configuration Information for the ripper application
class Config
  include BashHelper
  attr_accessor(
    :verbose, :scp_info, :type, :upload_path, :error_messages, :tv_season,
    :movie_name, :disc_number, :episode, :selected_disc_info, :log_directory,
    :ssh_password, :total_episodes, :maxlength, :include_extras,
    :mkv_from_file, :make_backup_path, :media_directory_path, :makemkvcon_path
  )
  attr_writer(:minlength)
  attr_reader(:movies)

  def self.configuration
    @configuration ||= Config.new
  end

  def initialize
    @makemkvcon_path = '/Applications/MakeMKV.app/Contents/MacOS/makemkvcon'
    self.error_messages = {}
    self.mkv_from_file = nil
    self.make_backup_path = nil
    self.upload_path = '/share/CE_CACHEDEV1_DATA/Multimedia'
    self.media_directory_path = File.join(%w[/ Volumes Multimedia])
    self.scp_info = 'newdark@10.0.0.139'
    self.verbose = false
    self.tv_season = 1
    self.disc_number = 1
    self.type = :movie
    self.movie_name = nil
    self.episode = 1
    self.selected_disc_info = nil
    self.log_directory = File.join([media_directory_path, 'logs'])
    self.ssh_password = nil
    self.total_episodes = 0
    self.minlength = nil
    self.maxlength = nil
    self.include_extras = false
    @movies = Movies.new
  end

  def reset!
    return if type != :movie

    self.movie_name = nil
  end

  def minlength
    return @minlength if @minlength
    return 3600 if type == :movie
    return 780 if type == :tv

    3600
  end

  def tv_season_to_word
    "season_#{tv_season}"
  end

  def disc_number_to_word
    "disc_#{disc_number}"
  end
end
