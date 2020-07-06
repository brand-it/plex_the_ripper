# frozen_string_literal: true

module Ripper
  class Server < Rack::App
    mount SetupController, to: '/setup'

    root '/setup'
  end
end
