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

      def find(tv:, season_number:)
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

      self.episodes = season.episodes.map do |episode|
        episode[:season] = self
        Episode.new(episode)
      end
    end

    def find_episode_by_number(number)
      return if number.nil?

      episodes.find { |e| e.episode_number == number }
    end
  end
end
