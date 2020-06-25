# frozen_string_literal: true

module TheMovieDb
  class Episode < Base
    option :name, type: Types::String
    option :episode_number, type: Types::Integer
  end
end
