# frozen_string_literal: true

class VideoSearchQuery
  extend Dry::Initializer
  VIDEOS_MEDIA_TYPE = %w[movie tv].freeze
  CACHE_TTL = 1.day

  option :query, Types::Coercible::String, optional: true
  option :page, Types::Coercible::Integer, default: -> { 1 }, optional: true, null: nil

  def results
    return @results if defined?(@results)
    return @results = Video.order(updated_at: :desc, synced_on: :desc).page(page) if query.blank?

    @results = Results.new(the_movie_db_ids.map { |db| find_video(**db) || build_video(**db) }.reverse, search, page)
  end

  def next_query
    { query: query, page: page + 1 } if results.next_page
  end

  private

  def search
    @search ||= TheMovieDb::Search::Multi.new(query: query, page: page).body
  end

  def video_results
    Rails.cache.fetch(
      { query: query, page: page },
      namespace: 'video_search_service',
      expires_in: CACHE_TTL,
      force: Rails.env.test?
    ) do
      search.results.select { |r| VIDEOS_MEDIA_TYPE.include?(r.media_type) }
    end
  end

  def the_movie_db_ids
    video_results.map { |r| { id: r.id, type: r.media_type.classify } }.reverse
  end

  def find_video(id: nil, type: nil)
    videos.find { |v| v.the_movie_db_id == id && v.type == type }
  end

  def videos
    @videos ||= VideosQuery.new(types_and_ids: the_movie_db_ids).relation.load
  end

  def build_video(id: nil, type: nil)
    Video.new(the_movie_db_id: id, type: type).tap do |video|
      "TheMovieDb::#{video.type}UpdateService".constantize.call(video)
    end
  end

  class Results
    extend Dry::Initializer
    include Enumerable

    delegate :each, :size, to: :results
    param :results
    param :search
    param :current_page

    def next_page
      results.respond_to?(:next_page) ? results.next_page : search_next_page
    end

    def search_next_page
      return if search.total_pages && search.total_pages <= current_page

      current_page + 1
    end
  end
end
