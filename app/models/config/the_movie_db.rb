# frozen_string_literal: true

class Config
  class TheMovieDb < Config
    settings_defaults(api_key: nil)

    def self.authorized?
      newest.first&.settings&.api_key.present?
    end
  end
end
