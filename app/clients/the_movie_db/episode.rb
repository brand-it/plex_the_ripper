# frozen_string_literal: true

module TheMovieDb
  class Episode < Base
    param :tv_id, Types::Integer
    param :season_number, Types::Integer
    param :episode_number, type: Types::Integer

    private

    def path
      "tv/#{tv_id}/season/#{season_number}/episode/#{episode_number}"
    end
  end
end
