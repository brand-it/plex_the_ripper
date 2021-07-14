# frozen_string_literal: true
require 'net/ftp'

class UploadMkvService
  extend Dry::Initializer

  option :disk_title, Types.Instance(DiskTitle)
  option :progress_listener, Types.Interface(:call)
  attr_writer :total_completed_bytes

  def call
    ftp.putbinaryfile(file, disk_title.video.plex_path) do |chunk|
      self.total_completed_bytes += chunk.size
      percentage = total_completed_bytes / file.size.to_f * 100
      progress_listener.call(percentage)
    end
  end

  private

  def total_completed_bytes
    @total_completed_bytes ||= 0
  end

  def file
    @file ||= File.new(disk_title.video.tmp_plex_path)
  end

  def ftp
    @ftp ||= Net::FTP.new(plex_config.settings_ftp_host, ftp_options)
  end

  def plex_config
    @plex_config ||= Config::Plex.newest.first
  end

  def ftp_options
    {
      username: plex_config.settings_ftp_username,
      password: plex_config.settings_ftp_password,
      ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
  end
end
