# frozen_string_literal: true

module Ftp
  class Base < ::ApplicationService
    option :max_retries, Types::Integer, default: -> { 20 }

    DEFAULT_RESCUES = [
      Errno::ECONNRESET,
      Errno::EINVAL,
      Errno::ENETUNREACH,
      Net::FTPTempError,
      Net::ReadTimeout,
      Net::WriteTimeout
    ].freeze

    def self.call(...)
      new(...).call
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
        username:,
        password: plex_config.settings_ftp_password,
        ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      }
    end

    # TODO: the rescue needs to be configurlable
    # try_to { download }
    # try_to { ftp.putbinaryfile(file, disk_title.plex_path) }
    def try_to(rescue_from = DEFAULT_RESCUES)
      @attempts ||= 0
      yield
    rescue *rescue_from => e
      raise e if @attempts >= max_retries

      Rails.logger.error "try_to #{@attempts} >= #{max_retries} #{e.class} #{e.message}"
      sleep(1 * @attempts += 1)
      @ftp = nil # reset the ftp client
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
