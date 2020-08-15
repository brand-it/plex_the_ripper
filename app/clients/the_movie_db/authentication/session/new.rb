# frozen_string_literal: true

module TheMovieDb
  class Authentication::Session::New < Base
      def results
        @results ||= get
      end
    end
  end
end
