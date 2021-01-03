# frozen_string_literal: true

# == Schema Information
#
# Table name: tvs
#
#  id               :integer          not null, primary key
#  backdrop_path    :string
#  episode_run_time :string
#  first_air_date   :string
#  name             :string
#  original_name    :string
#  overview         :string
#  poster_path      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  the_movie_db_id  :integer
#
require 'rails_helper'

RSpec.describe Tv, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:original_name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:seasons) }
  end
end
