# frozen_string_literal: true

module TheMovieDb
  module Authentication
    module Token
      class Response < Hash
        HOST = 'www.themoviedb.org'

        def request_url(params = nil)
          query = URI.encode_www_form(params) if params
          URI::HTTPS.build(host: HOST, path: "/authenticate/#{request_token}", query:)
        end
      end

      class New < Base
        def body
          @body ||= get(object_class: Response)
        end
      end
    end
  end
end
