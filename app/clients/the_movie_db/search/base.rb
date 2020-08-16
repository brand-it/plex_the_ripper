# frozen_string_literal: true

module TheMovieDb
  class Search::Base < Base
    option :page, type: Types::Integer, default: proc { 1 }, optional: true
    option :query, type: Types::Coercible::String
    option :year, type: Types::Integer.optional, optional: true

    def results
      return OpenStruct.new if query.blank?

      @results ||= get
    end

    def next_page
      @next_page ||= self.class.new(page: page + 1, query: query, year: year)
    end

    def previous_page
      @previous_page ||= self.class.new(page: page - 1, query: query, year: year)
    end

    # def model_name
    #   OpenStruct.new(param_key: 'search')
    # end

    # def to_key
    #   nil
    # end

    # def to_model
    #   self
    # end

    # def persisted?
    #   true
    # end
  end
end
