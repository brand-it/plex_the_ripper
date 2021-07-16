# frozen_string_literal: true

require 'net/ftp'

module Ftp
  class Base
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
end
