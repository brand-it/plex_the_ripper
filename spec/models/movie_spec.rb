# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id               :integer          not null, primary key
#  backdrop_path    :string
#  episode_run_time :string
#  first_air_date   :date
#  original_title   :string
#  overview         :string
#  poster_path      :string
#  release_date     :date
#  synced_on        :datetime
#  title            :string
#  type             :string
#  workflow_state   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  the_movie_db_id  :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Movie, type: :model do
  include_examples 'DiskWorkflow'
  include_examples 'HasProgress'
  include_examples 'IsVideo'

  # V
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:original_title) }
  end
end
