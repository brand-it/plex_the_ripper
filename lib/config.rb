# Configuration Information for the ripper application
class Config
  include BashHelper
  NUMBER_TO_WORD = {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    4 => 'four',
    5 => 'five',
    6 => 'six',
    7 => 'seven',
    8 => 'eight',
    9 => 'nine',
    10 => 'ten',
    11 => 'eleven',
    12 => 'twelve',
    13 => 'thirteen',
    14 => 'fourteen',
    15 => 'fifteen',
    16 => 'sixteen',
    17 => 'seventeen',
    18 => 'eighteen',
    19 => 'nineteen',
    20 => 'twenty',
    21 => 'twenty_one',
    22 => 'twenty_two',
    23 => 'twenty_three',
    24 => 'twenty_four',
    25 => 'twenty_five',
    26 => 'twenty_six',
    27 => 'twenty_seven',
    28 => 'twenty_eight',
    29 => 'twenty_nine',
    30 => 'thirty'
  }.freeze

  attr_accessor(
    :verbose, :scp_info, :type, :upload_path, :error_messages, :tv_season,
    :movie_name, :disc_number, :episode, :selected_disc_info, :log_directory,
    :ssh_password, :total_episodes, :maxlength, :file_path, :include_extras,
    :mkv_from_file, :make_backup_path
  )
  attr_writer(:minlength)
  attr_reader(:makemkvcon_path, :movies)

  def self.configuration
    @configuration ||= Config.new
  end

  def initialize
    @makemkvcon_path = '/Applications/MakeMKV.app/Contents/MacOS/makemkvcon'
    self.error_messages = {}
    self.mkv_from_file = nil
    self.make_backup_path = nil
    self.upload_path = '/share/CE_CACHEDEV1_DATA/Multimedia'
    self.file_path = File.join(%w[/ Volumes Multimedia])
    self.scp_info = 'newdark@10.0.0.139'
    self.verbose = false
    self.tv_season = 1
    self.disc_number = 1
    self.type = :movie
    self.movie_name = nil
    self.episode = 1
    self.selected_disc_info = nil
    self.log_directory = File.join([file_path, 'logs']) if file_path
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

  def ask_for_movie_name
    if movie_name.to_s != ''
      Logger.info("Name of #{type} is going to be #{movie_name.inspect}")
      return
    end
    self.movie_name = ask_value_required("What is the Name of this #{type}: ", type: String) do
      if selected_disc_info
        Logger.info(selected_disc_info.reload.describe)
      else
        DiscInfo.list_discs.each { |d| Logger.info(d.describe) }
      end
    end
  end

  def minlength
    return @minlength if @minlength
    return 3600 if type == :movie
    return 780 if type == :tv

    3600
  end

  def ask_for_tv_season
    return if type != :tv

    self.tv_season = ask_value_required(
      "What season is this (#{tv_season}): ",
      type: Integer, default: tv_season
    )
  end

  def ask_for_tv_episode
    return if type != :tv

    self.episode = ask_value_required(
      "What is the start episode (#{episode}): ",
      type: Integer, default: episode
    )
  end

  def ask_for_disc_number
    return if type != :tv

    self.disc_number = ask_value_required(
      "What is the disc number for (#{disc_number}): ",
      type: Integer, default: disc_number
    )
  end

  def valid?
    error_messages.empty?
  end

  def invalid?
    !valid?
  end

  def tv_season_to_word
    "season_#{tv_season}"
  end

  def disc_number_to_word
    "disc_#{disc_number}"
  end

  def file_path=(value)
    if File.exist?(value)
      @file_path = value
      error_messages.delete(:file_path)
    else
      error_messages[:file_path] = "File Path does not exist and is required #{value}"
    end
  end

  def makemkvcon_path=(value)
    if File.exist?(value)
      @makemkvcon_path = value
    else
      error_messages[:makemkvcon_path] = "could not find makemkvcon in #{value}"
    end
  end

  private
end
