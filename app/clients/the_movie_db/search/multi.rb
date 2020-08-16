# frozen_string_literal: true

module TheMovieDb
  module Search
    class Multi < Base
      def results
        @results ||= get
      end
    end
  end
end
