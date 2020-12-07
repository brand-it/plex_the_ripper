module MkvMaker
  class Base
    extend Dry::Initializer

    HOST = 'www.makemkv.com'
    option :redirect_limit, default: -> { 5 }

    private

    def get(uri = default_uri)
      response = Faraday.get(uri)
      case response.status
      when 301
        check_redirect_limit!
        increment_redirects_count
        get(response.env.response_headers['location'])
      else
        response
      end
    end

    def default_uri
      URI::HTTPS.build(host: HOST, path: path)
    end

    def path
      raise 'path is not defined in subclass'
    end

    def increment_redirects_count
      @total_redirects ||= 0
      @total_redirects += 1
    end

    def check_redirect_limit!
      return if @total_redirects <= redirect_limit

      raise "exceeded total of #{redirect_limit} 301 redirects"
    end
  end
end
