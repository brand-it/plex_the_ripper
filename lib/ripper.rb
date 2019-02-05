require File.expand_path('gem_installer', __dir__).to_s
extend GemInstaller
install 'pry'
require 'pry'
require File.expand_path('time_helper', __dir__).to_s
require File.expand_path('bash_helper', __dir__).to_s
require File.expand_path('humanizer_helper', __dir__).to_s
require File.expand_path('tv_shows_cleaner', __dir__).to_s
require File.expand_path('movies', __dir__).to_s
require File.expand_path('config', __dir__).to_s
require File.expand_path('disc_info', __dir__).to_s
require File.expand_path('makemkvcon', __dir__).to_s
require File.expand_path('opt_parser', __dir__).to_s
require File.expand_path('uploader', __dir__).to_s
require File.expand_path('logger', __dir__).to_s
require File.expand_path('notification', __dir__).to_s

class Ripper
  extend GemInstaller

  install 'nokogiri'
  install 'net-scp'
  install 'ruby-progressbar'

  require 'nokogiri'
  require 'set'
  require 'fileutils'
  require 'net/http'
  require 'uri'
  require 'net/scp'
  require 'json'
  require 'ruby-progressbar'

  extend BashHelper
  extend TimeHelper
  extend HumanizerHelper

  def self.check_file_path
    return if Config.configuration.file_path && File.exist?(Config.configuration.file_path)

    Logger.error("File path #{Config.configuration.file_path.inspect} is not present on this computer please change --file-path")
    abort
  end

  def self.start
    DiscSelector.perform
    # if Config.configuration.make_backup_path

    # else
    #   rip_disk
    # end

  rescue BashError => exception
    Logger.error(exception.message)
  rescue Interrupt
    Logger.info("\nThanks for using us have a wonderful day")
  end

  def self.rip_disk
    check_file_path
    while running
      ask_questions
      log_tv_info
      if Config.configuration.selected_disc_info
        Config.configuration.selected_disc_info.reload
      end
      which_disc?
      process
    end
  end

  def self.process
    show_wait_spinner('Waiting for disc to be inserted') do
      !Config.configuration.selected_disc_info.disc_present?
    end if Config.configuration.mkv_from_file.to_s == ''
    make_mkv = create_mkv
    if make_mkv.success?
      Logger.info(
        "#{Config.configuration.movie_name} "\
        "took #{human_seconds(make_mkv.run_time)} to rip"
      )
      Logger.log_rip_time(make_mkv.run_time, humanize_disk_info, make_mkv.size)
      # upload(Config.configuration.selected_disc_info, make_mkv)
      Config.configuration.disc_number += 1 # needs to be after upload started
    end
    Config.configuration.selected_disc_info.eject
    Config.configuration.reset!
  end

  def self.log_tv_info
    return if Config.configuration.type != :tv

    details = [
      Config.configuration.movie_name,
      Config.configuration.tv_season_to_word,
      Config.configuration.disc_number_to_word
    ].reject { |x| x.to_s == '' }.join(' ')
    Logger.info("Please insert #{details}")
  end

  def self.create_mkv
    make_mkv = MakeMKVCon.new
    make_mkv.create_mkv
    make_mkv
  end

  def self.upload(disc_info, make_mkv)
    uploader = Uploader.new(make_mkv)
    uploader.start_upload
    uploader
  end

  def self.delete_temp_file
    system!("rm -rf '#{Config.configuration.file_path}'")
  end

  def self.eject_disc
    disk_ejected = false
    tries = 1
    while disk_ejected == false
      Logger.info("(#{tries}) trying to ejecting disk", rewrite: true)
      system!('drutil eject external')
      disk_ejected = true if DiscInfo.find_disc.nil?
      tries += 1
    end
    Logger.success('Was able to eject disc')
  end

  def self.ask_questions
    sleep 1
    Config.configuration.ask_for_movie_name
    Config.configuration.ask_for_tv_season
    Config.configuration.ask_for_disc_number
    Config.configuration.ask_for_tv_episode
  end
end
