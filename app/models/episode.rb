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
class Episode < ApplicationRecord
  include DiskWorkflow
  belongs_to :season
  belongs_to :disk, optional: true
  belongs_to :disk_title, optional: true
end
