# frozen_string_literal: true

class VideoSearchService
  extend Dry::Initializer
  option :query, Types::Coercible::String, optional: true

  def results
    return Video.order(synced_on: :desc).limit(200) if query.blank?

    the_movie_db_ids.map do |db|
      find_video(**db) || create_video(**db)
    end.reverse
  end

  private

  def search
    @search ||= TheMovieDb::Search::Multi.new(query: query).body
  end

  def the_movie_db_ids
    search.results.map { |r| { id: r.id, type: r.media_type.classify } }.reverse
  end

  def find_video(id: nil, type: nil)
    videos.find { |v| v.the_movie_db_id == id && v.type == type }
  end

  def videos
    @videos ||= VideosQuery.new(types_and_ids: the_movie_db_ids).relation
  end

  def create_video(id: nil, type: nil)
    Video.new(the_movie_db_id: id, type: type).tap do |video|
      video.subscribe("TheMovieDb#{video.type}Listener".constantize.new)
      video.save!
    end
  end
end
