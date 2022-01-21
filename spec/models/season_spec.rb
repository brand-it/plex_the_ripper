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
require 'rails_helper'

RSpec.describe Season, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:season_number) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:episodes) }
    it { is_expected.to belong_to(:tv).optional(false) }
  end
end
