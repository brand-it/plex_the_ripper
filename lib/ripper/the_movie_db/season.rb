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

      def find(tv:, season_number:) # rubocop:disable UncommunicativeMethodParamName
        response = request("tv/#{tv.id}/season/#{season_number}")
        return if response.nil?

        response[:tv] = tv
        Season.new(response)
      end
    end

    def season
      @season ||= Season.find(tv: tv, season_number: season_number)
    end

    def episodes
      return @episodes if @episodes.any?

      self.episodes = season.episodes
    end

    def find_episode_by_number(number)
      return if number.nil?

      episode = episodes.find { |e| e['episode_number'].to_i == number }
      episode['season'] = self
      Episode.new(episode)
    end
  end
end
