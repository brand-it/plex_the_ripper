# frozen_string_literal: true

class VideoScannerService
  def call
    return if settings.nil?

    binding.pry
  end

  def ftp
    @ftp ||= Net::FTP.new(settings.ftp_host, ftp_options)
  end

  def config
    @config ||= Config::Plex.newest.first
  end

  def settings
    config&.settings
  end

  def ftp_options
    {
      username: settings.ftp_username,
      password: settings.ftp_password
    }
  end
end
