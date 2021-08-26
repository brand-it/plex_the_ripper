# frozen_string_literal: true

require 'net/ftp'

module Ftp
  class Base
    extend Dry::Initializer
    option :plex_config, default: -> { Config::Plex.newest }

    def self.call(*args)
      new(*args).call
    end

    def call
      raise "sub class #{class_name} needs to define method #call"
    end

    private

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

    def reset_connection!
      @ftp = nil
    end

    # TODO: the rescue needs to be configurlable
    def try_to(rescue_from = [Net::ReadTimeout, Errno::ECONNRESET, Errno::ENETUNREACH])
      @attempts ||= 0
      yield
    rescue *rescue_from => e
      raise e if @attempts >= max_retries

      reset_connection!
      Rails.logger.error e.message
      sleep(1 * @attempts)
      retry
    end

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
