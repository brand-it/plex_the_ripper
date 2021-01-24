module TheMovieDb
  class Error < StandardError
    attr_reader :object, :body

    def initialize(object)
      @object = object
      @body = JSON.parse(object.body, object_class: OpenStruct)
      super("#{object.env.url} #{object.status} #{object.body}")
    end
  end
end
