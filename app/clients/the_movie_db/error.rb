# frozen_string_literal: true

module TheMovieDb
  class Error < StandardError
    attr_reader :object, :body

    def initialize(object)
      @object = object
      @body = JSON.parse(object.body)
      super("#{object.env.url} #{object.status} #{object.body}")
    end
  end
end
