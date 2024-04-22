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
#  rating                       :integer          default("N/A"), not null
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
class Tv < Video
  alias_attribute :name, :title
  alias_attribute :original_name, :original_title

  serialize :episode_distribution_runtime, coder: JSON

  with_options unless: :the_movie_db_id do
    validates :name, presence: true
    validates :original_name, presence: true
  end

  has_many :seasons, dependent: :destroy

  before_save { broadcast(:tv_saving, self) }
  after_commit { broadcast(:tv_saved, id, async: true) }

  def min_max_run_time_seconds
    (episode_run_time.min * 60)..(episode_run_time.max * 60)
  end
end
