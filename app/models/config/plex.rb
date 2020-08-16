# frozen_string_literal: true

class Config
  class Plex < Config
    settings_defaults(movie_path: nil, video_path: nil)

    def settings_invalid?
      settings&.movie_path.blank? || settings&.video_path.blank?
    end
  end
end
