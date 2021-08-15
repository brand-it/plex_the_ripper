# frozen_string_literal: true

module TheMovieDb
  module Search
    class Movie < Base
      option :year, type: Types::Coercible::Integer.optional, optional: true
      option :primary_release_year, type: Types::Coercible::Integer.optional, optional: true
    end
  end
end
