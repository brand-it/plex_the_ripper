# frozen_string_literal: true

# == Schema Information
#
# Table name: episodes
#
#  id              :integer          not null, primary key
#  air_date        :date
#  episode_number  :integer
#  file_path       :string
#  name            :string
#  overview        :string
#  runtime         :integer
#  still_path      :string
#  workflow_state  :string
#  season_id       :bigint
#  the_movie_db_id :integer
#
# Indexes
#
#  index_episodes_on_season_id  (season_id)
#
require 'rails_helper'

RSpec.describe Episode do
  describe 'associations' do
    it { is_expected.to belong_to(:season).optional(false) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:episode_number) }
  end

  describe 'scopes' do
    it { is_expected.to have_scope(:order_by_episode_number).order(:episode_number) }
  end

  describe '#tv' do
    subject(:tv) { build_stubbed(:episode).tv }

    it { is_expected.to be_a(Tv) }
  end
end
