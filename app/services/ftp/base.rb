# frozen_string_literal: true

require 'net/ftp'

module Ftp
  class Base
    def ftp
      @ftp ||= Net::FTP.new(host, ftp_options)
    end

    def plex_config
      @plex_config ||= Config::Plex.newest
    end

    def ftp_options
      {
        username: username,
        password: plex_config.settings_ftp_password,
        ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      }
    end

    private

    def host
      plex_config.settings_ftp_host || raise(
        TheMovieDb::InvalidConfig, "#{plex_config.class} is missing host"
      )
    end

    def username
      plex_config.settings_ftp_username || raise(
        TheMovieDb::InvalidConfig, "#{plex_config.class} is missing a username"
      )
    end
  end
end
