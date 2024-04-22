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
#  disk_title_id                :bigint
#  the_movie_db_id              :integer
#
# Indexes
#
#  index_videos_on_disk_title_id             (disk_title_id)
#  index_videos_on_type_and_the_movie_db_id  (type,the_movie_db_id) UNIQUE
#
class Video < ApplicationRecord
  include Wisper::Publisher

  enum rating: { 'N/A': 0, NR: 1, 'NC-17': 2, R: 3, 'PG-13': 4, PG: 5, G: 6 }

  belongs_to :disk_title, optional: true
  has_many :video_blobs, dependent: :destroy
  has_many :optimized_video_blobs, lambda {
                                     VideoBlob.optimized
                                   }, class_name: 'VideoBlob', inverse_of: :video, dependent: :destroy

  scope :with_video_blobs, -> { includes(:video_blobs).where.not(video_blobs: { id: nil }) }
  scope :optimized, -> { includes(:optimized_video_blobs).where.not(video_blobs: { id: nil }) }
  scope :optimized_with_checksum, -> { optimized.merge(VideoBlob.checksum) }
  class << self
    def find_video(id)
      id.nil? ? find(id) : (find_by(the_movie_db_id: id) || find(id))
    end
  end

  def credits
    @credits ||= "TheMovieDb::#{type}::Credits".constantize.new(the_movie_db_id).results
  end

  def the_movie_db_details
    @the_movie_db_details ||= "TheMovieDb::#{type}".constantize.new(the_movie_db_id).results
  end

  def release_dates
    @release_dates ||= "TheMovieDb::#{type}::ReleaseDates".constantize.new(the_movie_db_id).results
  end

  def ratings
    @ratings ||= self.class.ratings.keys & release_dates['results']
                 .flat_map { _1['release_dates'] }
                 .pluck('certification')
  end

  def release_or_air_date
    release_date || episode_first_air_date
  end
end
