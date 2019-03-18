# frozen_string_literal: true

module TheMovieDB
  class Season < Model
    columns(
      name: String,
      season_number: Integer,
      episodes: Array,
      tv: TV
    )
    validate_presence(:number)
    validate_presence(:tv)

    class << self
      include TheMovieDBAPI

      def find(tv_id:, season_number:)
        request("tv/#{tv_id}/season/#{season_number}")
      end
    end

    def season
      @season ||= Season.find(tv_id: tv.id, season_number: season_number)
    end

    def episodes
      return @episodes if @episodes.any?

      self.episodes = season['episodes']
    end

    def find_episode_by_number(number)
      return if number.nil?

      episode = episodes.find { |e| e['episode_number'].to_i == number }
      episode['season'] = self
      Episode.new(episode)
    end
  end
end
