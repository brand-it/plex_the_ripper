# frozen_string_literal: true

module TheMovieDb
  class Base
    extend Dry::Initializer

    HOST = 'api.themoviedb.org'
    VERSION = '3'
    CACHE_TTL = 7.days
    CACHE_NAMESPACE = 'the_movie_db'
    class << self
      def option_names
        @option_names ||= dry_initializer.options.map(&:target)
      end

      def param_names
        @param_names ||= dry_initializer.params.map(&:target)
      end

      delegate :results, to: :new
    end

    def results(use_cache: true, object_class: Hash)
      @results ||= use_cache ? cache_get(object_class:) : get(object_class:)
    end

    private

    def cache_get(object_class: Hash)
      Rails.cache.fetch(
        [uri, query_params, object_class],
        namespace: CACHE_NAMESPACE,
        expires_in: CACHE_TTL,
        force: Rails.env.test?
      ) do
        get(object_class:)
      end
    end

    def get(object_class: Hash)
      response = connection.get(uri, query_params)

      return JSON.parse(response.body, object_class:) if response.success?

      raise Error, response
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.response :logger if Rails.application.config.faraday_logging
      end
    end

    def error!(response)
      Rails.logger.error(
        "#{response.error_type} #{response.message}" \
        " #{response.code} #{response.uri} #{response.body.strip}"
      )
      response.error!
    end

    def uri
      URI::HTTPS.build(host: HOST, path: ["/#{VERSION}", path].compact.join('/'))
    end

    def path
      self.class
          .name
          .split('::')[1..]
          .join('::')
          .parameterize(separator: '/')
    end

    def query_params
      { api_key:, langauge: language }.tap do |hash|
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
      Config::TheMovieDb.newest
    end
  end
end
