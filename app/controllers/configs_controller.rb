# frozen_string_literal: true

class ConfigsController < ApplicationController
  def new; end


  def index
    @configs = Config.all.page params[:page]
  end
end
