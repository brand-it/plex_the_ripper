# frozen_string_literal: true

class Season < Model
  columns(number: Integer, episodes: Array, tv_show: TVShow)
  validate_presence :number
  validate_presence :tv_show

  def add_episode(episode_number, episode_name, file_path)
    episode = find_episode(episode_number)
    return episode if episode

    episode = episodes.push(
      Episode.new(
        number: episode_number,
        season: self,
        file_path: file_path,
        name: episode_name
      )
    ).last
    episodes.sort_by!(&:number) # slow but who care... just not worth it to fix
    episode
  end

  def find_episode(episode_number)
    episodes.find { |s| s.number == episode_number }
  end
end
