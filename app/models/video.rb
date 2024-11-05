# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id                           :integer          not null, primary key
#  auto_start                   :boolean          default(FALSE), not null
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
class Video < ApplicationRecord
  include Wisper::Publisher
  enum :rating, { 'N/A': 0, NR: 1, 'NC-17': 2, R: 3, 'PG-13': 4, PG: 5, G: 6 }

  has_many :disk_titles, dependent: :nullify
  has_many :ripped_disk_titles, -> { ripped }, class_name: 'DiskTitle', dependent: false, inverse_of: :video
  has_many :video_blobs, dependent: :nullify
  has_many :optimized_video_blobs, lambda {
                                     VideoBlob.optimized
                                   }, class_name: 'VideoBlob', inverse_of: :video, dependent: :destroy

  scope :with_video_blobs, -> { includes(:video_blobs).where.not(video_blobs: { id: nil }) }
  scope :optimized, -> { includes(:optimized_video_blobs).where.not(video_blobs: { id: nil }) }
  scope :optimized_with_checksum, -> { optimized.merge(VideoBlob.checksum) }
  scope :auto_start, -> { where(auto_start: true) }
  scope :not_auto_start, -> { where.not(auto_start: true) }

  validates :title, presence: true

  def duration_stats
    @duration_stats ||= StatsService.call(ripped_disk_titles&.map(&:duration)&.compact_blank || [])
  end

  def movie?
    is_a?(::Movie)
  end

  def tv?
    is_a?(::Tv)
  end

  def credits
    return if the_movie_db_id.nil?

    @credits ||= "TheMovieDb::#{type}::Credits".constantize.new(the_movie_db_id).results
  end

  def the_movie_db_details
    return if the_movie_db_id.nil?

    @the_movie_db_details ||= "TheMovieDb::#{type}".constantize.new(the_movie_db_id).results
  end

  def release_dates
    return if the_movie_db_id.nil?

    @release_dates ||= "TheMovieDb::#{type}::ReleaseDates".constantize.new(the_movie_db_id).results
  end

  def ratings
    return [] if release_dates.nil?

    @ratings ||= self.class.ratings.keys & release_dates['results']
                 .flat_map { _1['release_dates'] }
                 .pluck('certification')
  end

  def release_or_air_date
    if is_a?(Movie)
      release_date
    elsif is_a?(Tv)
      episode_first_air_date
    end
  end

  def plex_name
    release_or_air_date ? "#{title} (#{release_or_air_date.year})" : title
  end
end
