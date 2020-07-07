# frozen_string_literal: true

require 'active_support/all'
require 'rack'

class Application < Rack::App
  class Config < OpenStruct
    def initialize
      super(ENV.to_h { |k, v| [k.downcase.to_sym, v] })
    end
  end

  class Router
    def initialize(request)
      @request = request
    end

    def route!
      binding.pry
      if @request.path == '/'
        [200, { 'Content-Type' => 'text/plain' }, ['Hello from the Router']]
      else
        not_found
      end
    end

    private

    def not_found(msg = 'Not Found')
      [404, { 'Content-Type' => 'text/plain' }, [msg]]
    end
  end

  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['APP_ENV'].presence || 'development')
    end

    def config
      @config ||= Config.new
    end

    def root
      @root ||= Pathname.new(File.expand_path('./', __dir__))
    end
  end

  def call(env)
    binding.pry
    request = Rack::Request.new(env)
    serve_request(request)
  end

  def serve_request(request)
    Router.new(request).route!
  end
end
