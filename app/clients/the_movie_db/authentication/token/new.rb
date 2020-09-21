# frozen_string_literal: true

module TheMovieDb
  module Authentication
    module Token
      class Response < OpenStruct
        HOST = 'www.themoviedb.org'

        def request_url(params = nil)
          query = URI.encode_www_form(params) if params
          URI::HTTPS.build(host: HOST, path: "/authenticate/#{request_token}", query: query)
        end
      end

      class New < Base
        def results
          @results ||= get(object_class: Response)
        end
      end
    end
  end
end
