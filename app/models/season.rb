# frozen_string_literal: true

# == Schema Information
#
# Table name: seasons
#
#  id              :integer          not null, primary key
#  air_date        :date
#  name            :string
#  overview        :string
#  poster_path     :string
#  season_number   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  the_movie_db_id :integer
#  tv_id           :bigint
#
# Indexes
#
#  index_seasons_on_tv_id  (tv_id)
#
class Season < ApplicationRecord
  include Wisper::Publisher

  has_many :episodes, -> { order_by_episode_number }, dependent: :destroy, inverse_of: :season
  has_many :disk_titles, through: :episodes
  has_many :ripped_disk_titles, -> { ripped }, through: :episodes, source: :disk_titles
  belongs_to :tv

  scope :order_by_season_number, -> { order(:season_number) }

  validates :season_number, presence: true

  before_save { broadcast(:season_saving, self) }
  after_commit { broadcast(:season_saved, id, async: true) }

  def season_name
    "Season #{format_season_number}"
  end

  def format_season_number
    format('%02d', season_number)
  end
end
