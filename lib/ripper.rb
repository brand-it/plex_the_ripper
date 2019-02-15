require File.expand_path('base', __dir__).to_s

class Ripper
  extend TimeHelper
  extend HumanizerHelper
  class Abort < RuntimeError; end

  class << self
    def perform
      threads = []
      threads << Thread.new do
        AskForDiscSelector.perform
        AskForFilePathBuilder.perform
        AskForVideoDetails.perform
        AskForMovieDetails.perform
        AskForTVDetails.perform
      end
      threads << Thread.new { VideosLoader.perform }
      threads << Thread.new { LoadDiscDetails.perform }
      threads.each(&:join)
      Shell.puts_buffer
      DuplicateChecker.perform
      CreateMKV::Movie.perform
      CreateMKV::TV.perform
      Config.configuration.selected_disc_info.eject
      Config.configuration.reset!
      Ripper.perform
    rescue Ripper::Abort => exception
      Logger.warning(exception.message)
      Config.configuration.selected_disc_info.eject
      Config.configuration.reset!
      Ripper.perform
    end

    def rip_disk
      process while running
    end

    def process
      make_mkv = create_mkv
      if make_mkv.success?
        Logger.info(
          "#{Config.configuration.video_name} "\
          "took #{human_seconds(make_mkv.run_time)} to rip"
        )
        Logger.log_rip_time(make_mkv.run_time, humanize_disk_info, make_mkv.size)
        # upload(Config.configuration.selected_disc_info, make_mkv)
        Config.configuration.disc_number += 1 # needs to be after upload started
      end
      Config.configuration.selected_disc_info.eject
      Config.configuration.reset!
    end

    def self.create_mkv
      make_mkv = MakeMKV.new
      make_mkv.create_mkv
      make_mkv
    end

    def self.upload(_disc_info, make_mkv)
      uploader = Uploader.new(make_mkv)
      uploader.start_upload
      uploader
    end

    def self.delete_temp_file
      Shell.system!("rm -rf '#{Config.configuration.file_path}'")
    end

    def self.eject_disc
      disk_ejected = false
      tries = 1
      while disk_ejected == false
        Logger.info("(#{tries}) trying to ejecting disk", rewrite: true)
        Shell.system!('drutil eject external')
        disk_ejected = true if DiscInfo.find_disc.nil?
        tries += 1
      end
      Logger.success('Was able to eject disc')
    end
  end

  # def self.log_tv_info
  # return if Config.configuration.type != :tv

  # details = [
  #   Config.configuration.video_name,
  #   Config.configuration.tv_season_to_word,
  #   Config.configuration.disc_number_to_word
  # ].reject { |x| x.to_s == '' }.join(' ')
  # Logger.info("Please insert #{details}")
  # end
end
