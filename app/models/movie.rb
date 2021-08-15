# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  backdrop_path                :string
#  episode_distribution_runtime :string
#  episode_first_air_date       :date
#  movie_runtime                :integer
#  original_title               :string
#  overview                     :string
#  popularity                   :float
#  poster_path                  :string
#  release_date                 :date
#  synced_on                    :datetime
#  title                        :string
#  type                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  disk_title_id                :bigint
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_disk_title_id             (disk_title_id)
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Movie < Video
  before_save { broadcast(:movie_saving, self) }
  after_commit { broadcast(:movie_saved, id) }

  MOVIE_RUNNTIME_MARGIN = 10.minutes.to_i

  with_options unless: :the_movie_db_id do
    validates :title, presence: true
    validates :original_title, presence: true
  end

  def runtime_range
    (movie_runtime - MOVIE_RUNNTIME_MARGIN)..(movie_runtime + MOVIE_RUNNTIME_MARGIN)
  end

  def plex_path
    raise 'plex config is missing and is required' unless Config::Plex.any?

    @plex_path ||= Pathname.new("#{Config::Plex.newest.settings_movie_path}/#{plex_name}/#{plex_name}.mkv")
  end

  def tmp_plex_path
    @tmp_plex_path ||= Rails.root.join("tmp/movies/#{plex_name}/#{plex_name}.mkv")
  end

  def plex_name
    @plex_name ||= (release_date ? "#{title} (#{release_date.year})" : title)
  end

  def update_maxlength(max)
    return config.maxlength = (max + MOVIE_DURATION_MARGIN) if max.to_i > (config.minlength / 60)

    config.maxlength = nil
  end
end
