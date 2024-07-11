# frozen_string_literal: true

module TheMovieDb
  class EpisodesListener
    def season_saving(season)
      TheMovieDb::EpisodeUpdateService.call(season)
    end
  end
end
