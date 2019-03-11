# frozen_string_literal: true

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class OptParser
  def self.parse(args) # rubocop:disable AbcSize, MethodLength, CyclomaticComplexity
    opt_parser = OptionParser.new do |opts| # rubocop:disable Metrics/BlockLength
      opts.banner = 'Usage: rip [options]'

      opts.separator ''
      opts.separator 'Specific options:'
      opts.on(
        '-i', '--include-extras',
        'All other titles that are not the main movie will be added to the "Behind The Scenes" '\
         'folder so plex can watch them. This will set the --min-length "\
         "to zero unless --min-length option is used'
      ) do
        Config.configuration.include_extras = true
      end

      opts.on('-a', '--api-key [Key]', String, 'API key provide by themoviedb.org') do |value|
        Config.configuration.the_movie_db_config.api_key = value
      end

      opts.on(
        '-u',
        '--slack-url [URL]',
        String,
        'Slack Web Hook. Can be handy if you want to notify a '\
        'channel of the progress or details of how the rip is going'
      ) do |value|
        Config.configuration.slack_url = value
      end

      opts.on(
        '-r', '--media-folder [Folder]', String,
        'Where would you like use to rip the files to.'\
        " (#{Config.configuration.media_directory_path.inspect})"
      ) do |value|
        Config.configuration.media_directory_path = value
      end

      opts.on(
        '--make-backup [BackupFolder]', String,
        'Make a disk backup rather than ripping the movie'
      ) do |value|
        unless File.exist?(value)
          puts "Backup path does not exist #{value}"
          exit 1
        end
        Config.configuration.make_backup_path = value
      end

      opts.on(
        '-l', '--min-length [SECONDS]', Integer,
        'The minimum amount of time that a video length should be. Exlude '\
        "anything less than (#{Config.configuration.minlength.inspect}) seconds"
      ) do |value|
        Config.configuration.minlength = value
      end

      opts.on(
        '-x', '--max-length [SECONDS]', Integer,
        'The max amount of time that a video length should be. Anything less '\
        "than will not be copied (#{Config.configuration.maxlength.inspect})"
      ) do |value|
        Config.configuration.maxlength = value
      end

      opts.on(
        '-s', '--tv-season [NUMBER]', Integer, 'Provide the season number if TV show'
      ) do |value|
        Config.configuration.tv_season = value
      end

      opts.on(
        '-t', '--type [TYPE]', %i[tv movie], 'Set the type disc type (tv, movie)'
      ) do |type|
        Logger.warning('Could not resolve your type default is :movie') if type.nil?
        Config.configuration.type = type || :movie
      end

      opts.on('-e', '--episode-number [NUMBER]', Integer, 'TV episode number') do |number|
        Config.configuration.episode = number || 1
      end

      opts.on('-d', '--disc-number [NUMBER]', Integer, 'TV session disc number') do |number|
        Logger.warning('Disc number is blank defaulting to 1') if number.nil?
        Config.configuration.disc_number = number || 1
      end

      opts.on(
        '-m', '--movie-name [NAME]',
        'Name of the movie or TV show'
      ) do |value|
        Config.configuration.video_name = value
      end

      opts.on(
        '-f', '--file-source [FolderName]', String,
        'If you want open files in folder <FolderName>'
      ) do |value|
        Config.configuration.mkv_from_file = value
      end

      # Boolean switch.
      opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        Config.configuration.verbose = v
      end

      opts.on_tail('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end
    opt_parser.parse!(args)
  end
end
