class Ripper
  extend BashHelper
  extend TimeHelper
  extend HumanizerHelper

  def self.perform
    FileChecker.perform
    DiscSelector.perform
    AskForMovieDetails.perform
    AskForTVDetails.perform
  end

  def self.rip_disk
    process while running
  end

  def self.process
    if Config.configuration.mkv_from_file.to_s == ''
      show_wait_spinner('Waiting for disc to be inserted') do
        !Config.configuration.selected_disc_info.disc_present?
      end
    end
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

  # def self.log_tv_info
  # return if Config.configuration.type != :tv

  # details = [
  #   Config.configuration.movie_name,
  #   Config.configuration.tv_season_to_word,
  #   Config.configuration.disc_number_to_word
  # ].reject { |x| x.to_s == '' }.join(' ')
  # Logger.info("Please insert #{details}")
  # end

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
end
