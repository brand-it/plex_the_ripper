# frozen_string_literal: true

module TheMovieDb
  class Season < Base
    param :tv_id, Types::Integer
    param :season_number, Types::Integer

    def results
      @results ||= get
    end

    private

    def path
      "tv/#{tv_id}/season/#{season_number}"
    end
  end
end
