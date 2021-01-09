# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id               :integer          not null, primary key
#  backdrop_path    :string
#  episode_run_time :string
#  first_air_date   :string
#  original_title   :string
#  overview         :string
#  poster_path      :string
#  release_date     :date
#  title            :string
#  type             :string
#  workflow_state   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  the_movie_db_id  :integer
#
class Tv < Video
  include Wisper::Publisher
  alias_attribute :name, :title
  alias_attribute :original_name, :original_title

  serialize :episode_run_time, Array

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
