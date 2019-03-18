# frozen_string_literal: true

module TheMovieDB
  class Episode < Model
    columns(name: String, episode_number: Integer)
  end
end
