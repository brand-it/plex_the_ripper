# frozen_string_literal: true

module TheMovieDb
  class InvalidConfig < StandardError; end

  class Error < StandardError
    attr_reader :object, :body

    def initialize(object)
      @object = object
      @body = JSON.parse(object.body, object_class: OpenStruct)
      super("#{object.env.url} #{object.status} #{object.body}")
    end
  end

  class Base
    extend Dry::Initializer

    HOST = 'api.themoviedb.org'
    VERSION = '3'

    class << self
      def option_names
        @option_names ||= dry_initializer.options.map(&:target)
      end

      def param_names
        @param_names ||= dry_initializer.params.map(&:target)
      end

      delegate :results, to: :new
    end

    private

    def get(object_class: OpenStruct)
      response = Faraday.get(uri, query_params)

      return JSON.parse(response.body, object_class: object_class) if response.success?

      raise Error, response
    end

    def error!(response)
      Rails.logger.error(
        "#{response.error_type} #{response.message} #{response.code} #{response.uri} #{response.body.strip}"
      )
      response.error!
    end

    def uri
      URI::HTTPS.build(host: HOST, path: ["/#{VERSION}", path, path_params].compact.join('/'))
    end

    def path
      self.class
          .name
          .split('::')[1..]
          .join('::')
          .parameterize(separator: '/')
    end

    def path_params
      self.class.param_names.map { |name| send(name) }.join('/').presence
    end

    def query_params
      { api_key: api_key, langauge: language }.tap do |hash|
        self.class.option_names.each do |name|
          hash[name] = send(name)
        end
      end.compact.with_indifferent_access
    end

    # Visit to get api key https://www.themoviedb.org/settings/api
    def api_key
      config.settings.api_key.tap do |key|
        raise InvalidConfig, 'the movie db api requires an api key' if key.blank?
      end
    end

    # Pass a ISO 639-1 value to display translated data for the fields that support it.
    # minLength: 2
    # pattern: ([a-z]{2})-([A-Z]{2})
    # default: en-US
    def language
      config.settings.langauge
    end

    def config
      @config ||= Config::TheMovieDb.newest.first || Config::TheMovieDb.new
    end
  end
end
