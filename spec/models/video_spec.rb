# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  backdrop_path                :string
#  episode_distribution_runtime :string
#  episode_first_air_date       :date
#  movie_runtime                :integer
#  original_title               :string
#  overview                     :string
#  popularity                   :float
#  poster_path                  :string
#  rating                       :integer          default("N/A"), not null
#  release_date                 :date
#  synced_on                    :datetime
#  title                        :string
#  type                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Video do
  describe 'associations' do
    it { is_expected.to have_many(:disk_titles).dependent(:nullify) }
    it { is_expected.to have_many(:video_blobs).dependent(:destroy) }
    it { is_expected.to have_many(:optimized_video_blobs).dependent(:destroy) }
  end
end
