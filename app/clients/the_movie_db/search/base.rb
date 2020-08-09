module TheMovieDb
  module Search
    class Base < TheMovieDb::Base
      option :page, type: Types::Integer, default: proc { 1 }, optional: true
      option :query, type: Types::String
      option :year, type: Types::Integer.optional, optional: true

      def results
        @results ||= OpenStruct.new(get)
      end

      def next_page
        @next_page ||= self.class.new(page: page + 1, query: query, year: year)
      end

      def previous_page
        @previous_page ||= self.class.new(page: page - 1, query: query, year: year)
      end
    end
  end
end
