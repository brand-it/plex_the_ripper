# frozen_string_literal: true

class Config
  class Plex < Config
    settings_defaults(
      movie_path: nil, video_path: nil,
      ftp_username: nil, ftp_host: nil, ftp_password: nil,
      use_ftp: false
    )

    def settings_invalid?
      settings.movie_path.blank? || settings.video_path.blank?
    end

    def settings_use_ftp?
      settings.use_ftp == true
    end
  end
end
