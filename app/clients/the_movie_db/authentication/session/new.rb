# frozen_string_literal: true

module TheMovieDb
  module Authentication
    module Session
      class New < Base
        def results
          @results ||= get
        end
      end
    end
  end
end
