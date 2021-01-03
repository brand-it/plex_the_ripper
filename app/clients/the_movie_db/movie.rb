# frozen_string_literal: true

module TheMovieDb
  class Movie < Base
    param :movie_id, Types::Integer

    def results
      @results ||= get
    end

    private

    def path
      "movie/#{movie_id}"
    end
  end
end
