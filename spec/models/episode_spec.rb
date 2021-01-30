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

RSpec.describe Episode, type: :model do
  include_examples 'DiskWorkflow'

  describe 'associations' do
    it { is_expected.to belong_to(:season) }
  end
end
