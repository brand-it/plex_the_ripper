module Ripper
  class Server < Rack::App
    mount SetupController, to: '/setup'

    root '/setup'
  end
end
