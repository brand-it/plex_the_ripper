# frozen_string_literal: true

module TheMovieDB
  class Episode < Model
    include TheMovieDBAPI
    columns(name: String, episode_number: Integer, season: Season)

    validate_presence(:number)

    # request a specific episode using the API
    def episode(season_number:, episode_number:)
      request("tv/#{tv_id}/season/#{season_number}/episode/#{episode_number}")
    end
  end
end
