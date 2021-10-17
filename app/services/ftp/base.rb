# frozen_string_literal: true

require 'net/ftp'

module Ftp
  class Base
    extend Dry::Initializer
    option :plex_config, default: -> { Config::Plex.newest }
    option :max_retries, Types::Integer, default: -> { 20 }

    DEFAULT_RESCUES = [
      Errno::ECONNRESET,
      Errno::EINVAL,
      Errno::ENETUNREACH,
      Net::ReadTimeout
    ].freeze

    def self.call(*args)
      new(*args).call
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

    # TODO: the rescue needs to be configurlable
    def try_to(rescue_from = DEFAULT_RESCUES)
      @attempts ||= 0
      yield
    rescue *rescue_from => e
      raise e if @attempts >= max_retries

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
