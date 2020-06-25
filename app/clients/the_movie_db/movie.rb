# frozen_string_literal: true

module TheMovieDB
  class Movie < Model
    attr_accessor(:loaded)
    option :title, type: Types::String
    option :id, type: Types::Integer
    option :runtime, type: Types::Integer.optional
    option :release_date, type: Types::String.optional

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
