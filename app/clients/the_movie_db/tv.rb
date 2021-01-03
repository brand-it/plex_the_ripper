# frozen_string_literal: true

module TheMovieDb
  class Tv < Base
    param :tv_id, Types::Integer

    def results
      @results ||= get
    end

    private

    def path
      "tv/#{tv_id}"
    end
  end
end
