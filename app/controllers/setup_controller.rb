# frozen_string_literal: true

class SetupController < ApplicationController
  get '/setup' do
    slim :index
  end
end
