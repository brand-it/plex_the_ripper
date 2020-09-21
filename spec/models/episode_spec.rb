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
#  disk_id         :integer
#  disk_title_id   :integer
#  season_id       :integer
#  the_movie_db_id :integer
#
# Indexes
#
#  index_episodes_on_disk_id        (disk_id)
#  index_episodes_on_disk_title_id  (disk_title_id)
#  index_episodes_on_season_id      (season_id)
#
require 'rails_helper'

RSpec.describe Episode, type: :model do
  include_context 'DiskWorkflow'
  describe 'associations' do
    it { is_expected.to belong_to(:season) }
    it { is_expected.to belong_to(:disk).optional(true) }
    it { is_expected.to belong_to(:disk_title).optional(true) }
  end
end
