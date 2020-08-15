# frozen_string_literal: true

module TheMovieDb
  class InvalidConfig < StandardError; end
  class Base
    extend Dry::Initializer

    HOST = 'api.themoviedb.org'
    VERSION = '3'

    class << self
      def option_names
        @option_names ||= dry_initializer.options.map(&:target)
      end

      def results
        new.results
      end

      def session_id
        @session_id
      end
    end

    private

    def get(redirect_uri: nil, limit: 10, object_class: OpenStruct) # rubocop:disable Metrics/MethodLength
      response = Net::HTTP.get_response(redirect_uri || uri)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body, object_class: object_class)
      when Net::HTTPRedirection
        location = response['location']
        Rails.logger.warn "redirected to #{location}"
        get(redirect_uri: URI(location), limit: limit - 1, object_class: object_class)
      else
        error!(response)
      end
    end

    def error!(response)
      Rails.logger.debug(
        "#{response.error_type} #{response.message} #{response.code} #{response.uri} #{response.body.strip}"
      )
      response.error!
    end

    # def http
    #   Net::HTTP.new(uri.host, uri.port)
    # end

    # def request
    #   Net::HTTP::Get.new(uri).tap do |request|
    #     # don't know why but they want data in the body but it creates problem if you don't have it
    #     # really I not total sure it is needed however better safe then sorry.
    #     request.body = body.to_json
    #   end
    # end

    # def body
    #   {}
    # end

    def uri
      URI::HTTPS.build(host: HOST, path: "/#{VERSION}/#{path}", query: URI.encode_www_form(params))
    end

    def path
      self.class
          .name
          .split('::')[1..]
          .join('::')
          .parameterize(separator: '/')
    end

    def params
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

    # def config
    #   return @config if @config

    #   @config = Config.configuration.the_movie_db_config
    #   return @config if @config.is_a?(TheMovieDbConfig)

    #   raise(
    #     Plex::Ripper::Abort,
    #     'The Movie DB Config should not be nil but some how it is. Create a issue in github please'
    #   )
    # end
  end
end
