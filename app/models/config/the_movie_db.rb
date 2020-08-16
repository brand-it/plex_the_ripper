# frozen_string_literal: true

class Config
  class TheMovieDb < Config
    settings_defaults(api_key: nil)

    def settings_invalid?
      settings&.api_key.blank?
    end
  end
end
