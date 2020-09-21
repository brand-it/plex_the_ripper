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
#  tv_id           :integer
#
# Indexes
#
#  index_seasons_on_tv_id  (tv_id)
#
class Season < ApplicationRecord
  include Wisper::Publisher

  has_many :episodes
  belongs_to :tv

  validates :season_number, presence: true

  before_save { broadcast(:season_saving, self) }
  after_commit { broadcast(:season_saved, id, async: true) }
end
