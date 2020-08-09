# frozen_string_literal: true

class Config
  class User < Config
    SETTINGS_DEFAULTS = {
      api_key: nil
    }.freeze
  end
end
