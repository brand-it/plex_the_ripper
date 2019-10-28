# frozen_string_literal: true

module TheMovieDB
  class Movie < Model
    attr_accessor(:loaded)
    columns(
      title: String,
      id: Integer,
      runtime: Integer,
      release_date: String
    )
    validate_presence(:id)

    class << self
      include TheMovieDBAPI
      def find(id)
        movie = video(type: :movie, id: id)
        return if movie.nil?

        Movie.new(movie)
      end

      def search(query, page: 1)
        super(page: page, query: query, type: :movie).map do |movie|
          Movie.new(movie)
        end
      end
    end

    def release_date_to_time
      @release_date_to_time ||= Time.parse(release_date)
    end

    def release_date_present?
      release_date.to_s != ''
    end

    # TV show use name this helps normalize the data
    def name
      title
    end

    def runtime
      load_more
      { min: @runtime, max: @runtime }
    end

    # load more of the data if more is needed. This is useful for in the
    # case of runtime not being present
    def load_more
      return if loaded

      update(Movie.video(type: :movie, id: id))
      self.loaded = true
    end
  end
end
