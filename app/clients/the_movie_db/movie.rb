# frozen_string_literal: true

module TheMovieDb
  class Movie < Base
    param :movie_id, Types::Integer

    def results
      @results ||= get
    end
  end
end
