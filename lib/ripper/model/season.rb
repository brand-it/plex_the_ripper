# frozen_string_literal: true

class Season < Model
  columns(number: Integer, episodes: Array, tv_show: TVShow)
  validate_presence :number
  validate_presence :tv_show

  def add_episode(episode_number, file_path)
    episode = find_episode(episode_number)
    episode || episodes.push(
      Episode.new(number: episode_number, season: self, file_path: file_path)
    ).last
  end

  def find_episode(episode_number)
    episodes.find { |s| s.number == episode_number }
  end
end
