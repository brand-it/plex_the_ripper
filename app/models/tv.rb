# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  auto_start                   :boolean          default(FALSE), not null
#  backdrop_path                :string
#  episode_distribution_runtime :string
#  episode_first_air_date       :date
#  movie_runtime                :integer
#  original_title               :string
#  overview                     :string
#  popularity                   :float
#  poster_path                  :string
#  rating                       :integer          default("N/A"), not null
#  release_date                 :date
#  title                        :string
#  type                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Tv < Video
  alias_attribute :name, :title
  alias_attribute :original_name, :original_title

  serialize :episode_distribution_runtime, coder: JSON

  with_options unless: :the_movie_db_id do
    validates :name, presence: true
    validates :original_name, presence: true
  end

  has_many :seasons, -> { order_by_season_number }, dependent: :destroy, inverse_of: :tv
  has_many :episodes, ->  { order_by_episode_number }, through: :seasons

  before_validation { broadcast(:tv_validating, self) }
  before_save { broadcast(:tv_saving, self) }
  after_commit { broadcast(:tv_saved, self) }

  def duration_range
    return if ripped_disk_titles_durations.empty? && episodes_runtime.empty?

    range = round_up_to_nearest_minute(
      duration_stats.interquartile_range ||
      episode_runtime_stats.interquartile_range ||
      DEFAULT_RANGE
    )
    average_runtime = duration_stats.weighted_average ||
                      episode_runtime_stats.weighted_average

    return if average_runtime.nil?

    (average_runtime - range)..(average_runtime + range)
  end

  def episode_runtime_stats
    @episode_runtime_stats ||= StatsService.call(episodes_runtime)
  end

  def episodes_runtime
    @episodes_runtime ||= episodes.map(&:runtime).uniq.compact_blank
  end
end
