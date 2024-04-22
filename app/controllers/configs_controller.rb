# frozen_string_literal: true

class ConfigsController < ApplicationController
  def index
    @configs = Config.all.page params[:page]
  end

  def new; end
end
