# frozen_string_literal: true

module TheMovieDb
  module Authentication
    module Session
      class New < Base
        def body
          @body ||= get
        end
      end
    end
  end
end
