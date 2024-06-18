# frozen_string_literal: true

class VideoSearchQuery
  extend Dry::Initializer
  VIDEOS_MEDIA_TYPE = %w[movie tv].freeze
  RESULTS_PER_PAGE = 21 # the movie db comes back with 20 results per page

  option :query, Types::Coercible::String, optional: true
  option :page, Types::Coercible::Integer, default: -> { 1 }, optional: true, null: nil

  def results
    return @results if defined?(@results)
    return @results = Video.order(popularity: :desc).includes(:video_blobs).page(page) if query.blank?

    db_results = the_movie_db_ids.map { find_or_build_video(**_1) }
    @results = Results.new db_results, search, page
  end

  def next_query
    { query:, page: page + 1 } if results.next_page
  end

  private

  def search
    @search ||= TheMovieDb::Search::Multi.new(query:, page:).results
  end

  def the_movie_db_ids
    return @the_movie_db_ids if @the_movie_db_ids

    @the_movie_db_ids = video_results.map { { data: _1, id: _1['id'], type: _1['media_type'].classify } }
  end

  def video_results
    search['results'].select { VIDEOS_MEDIA_TYPE.include?(_1['media_type']) }
  end

  def videos
    @videos ||= VideosQuery.new(types_and_ids: the_movie_db_ids)
                           .relation.includes(:video_blobs).load
  end

  # {
  #   'adult' => false,
  #   'backdrop_path' => '/jqFC2WjYF07hx2X7cs0XmY9jBX6.jpg',
  #   'genre_ids' => [878],
  #   'id' => 1_003_598,
  #   'media_type' => 'movie',
  #   'original_language' => 'en',
  #   'original_title' => 'Avengers: Secret Wars',
  #   'overview' => 'An upcoming film in Phase 6 of the Marvel Cinematic Universe and the',
  #   'popularity' => 22.216,
  #   'poster_path' => '/8chwENebfUEJzZ7sMUA0nOgiCKk.jpg',
  #   'release_date' => '2027-05-05',
  #   'title' => 'Avengers: Secret Wars',
  #   'video' => false,
  #   'vote_average' => 0.0,
  #   'vote_count' => 0
  # }
  # {
  #   'adult' => false,
  #   'backdrop_path' => '/44TJgVKPto88kOF2R036dgkjJms.jpg',
  #   'first_air_date' => '1999-10-30',
  #   'genre_ids' => [16, 10_759, 10_765],
  #   'id' => 1300,
  #   'media_type' => 'tv',
  #   'name' => 'The Avengers: United They Stand',
  #   'origin_country' => ['US']
  #   'original_language' => 'en',
  #   'original_name' => 'The Avengers: United They Stand',
  #   'overview' => 'When the planet is threatened by Super Villains',
  #   'popularity' => 15.278,
  #   'poster_path' => '/p2SrnKTQjLRXBCcTZtYkTZCwLpp.jpg',
  #   'vote_average' => 5.8,
  #   'vote_count' => 18,
  # }
  def find_or_build_video(data: nil, id: nil, type: nil)
    videos.find { _1.the_movie_db_id == id && _1.type == type } ||
      Video.new(the_movie_db_id: id, type:).tap do |video|
        "TheMovieDb::#{video.type}UpdateService".constantize.call(video, data)
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
      return if search['total_pages'] && search['total_pages'] <= current_page

      current_page + 1
    end
  end
end
