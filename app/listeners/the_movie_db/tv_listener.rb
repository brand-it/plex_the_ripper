# frozen_string_literal: true

module TheMovieDb
  class TvListener
    def tv_saving(tv) # rubocop:disable Naming/MethodParameterName
      TheMovieDb::TvUpdateService.call(tv)
    end
  end
end
