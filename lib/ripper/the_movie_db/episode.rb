# frozen_string_literal: true

module TheMovieDB
  class Episode < Model
    columns(name: String, episode_number: Integer, air_date: String)

    def air_date=(value)
      @air_date = Time.parse(value) if value
    end
  end
end
