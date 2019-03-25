# frozen_string_literal: true

class TVShow < Model
  PATTERN_ONE = /\A(?<name>.*)(\s|)\-(\s|)s(?<season>\d\d)e(?<episode>\d\d)(\s|)\-(\s|)(?<episode_name>.*)/.freeze
  PATTERN_TWO = /\A(?<name>.*)\ss(?<season>\d\d)e(?<episode>\d\d)(\s|)\-(\s|)(?<episode_name>.*)/.freeze

  columns(title: String, seasons: Array, video: Videos, directory: String)
  validate_presence(:title)
  validate_presence(:video)
  validate_presence(:directory)

  class << self
    def mkv_path_to_hash(mkv_path)
      name = Videos.get_name_from_path(mkv_path, Config.configuration.tv_shows_directory_name)
      match = mkv_path_to_match(mkv_path)
      season = 0
      episode = 0
      episode_name = nil
      if match.is_a?(MatchData)
        season = match[:season].to_i
        episode = match[:episode].to_i
        episode_name = match[:episode_name]
      end
      {
        title: name,
        season: season,
        episode: episode,
        file_path: mkv_path,
        episode_name: episode_name,
        directory: [
          Config.configuration.media_directory_path,
          Config.configuration.tv_shows_directory_name,
          name
        ].join('/')
      }
    end

    private

    def mkv_path_to_match(mkv_path)
      basename = File.basename(mkv_path, '.mkv')
      [PATTERN_ONE, PATTERN_TWO].each do |pattern|
        match = basename.match(pattern)
        return match if match
      end
      nil
    end
  end
  def add_season(season_number)
    season = find_season(season_number)
    season || seasons.push(
      Season.new(number: season_number, tv_show: self)
    ).last
  end

  def find_season(season_number)
    seasons.find { |s| s.number == season_number }
  end
end
