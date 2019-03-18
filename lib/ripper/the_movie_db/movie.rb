# frozen_string_literal: true

module TheMovieDB
  class Movie < Model
    columns(
      title: String,
      id: Integer,
      runtime: Integer,
      first_air_date: String
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
        super(page: page, query: query, type: :movie).map do |tv_show|
          Movie.new(tv_show)
        end
      end
    end

    # TV show use name this helps normalize the data
    def name
      title
    end

    def runtime
      { min: @runtime, max: @runtime }
    end
  end
end
