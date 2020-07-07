# frozen_string_literal: true

class ApplicationController < Sinatra::Application
  set :root, Application.root.join('app')
end
