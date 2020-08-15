# frozen_string_literal: true

class Config
  class User < Config
    settings_defaults(
      dark_mode: true,
      the_movie_db_api_key: nil,
      the_movie_db_session_id: nil
    )
  end
end
