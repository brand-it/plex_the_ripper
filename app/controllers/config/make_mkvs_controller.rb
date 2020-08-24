# frozen_string_literal: true

class Config::MakeMkvsController < ApplicationController
  before_action :set_make_mkv, only: %i[show edit update destroy]

  def edit; end

  def update
    flash[:success] = 'Updated Make MKV' if @config_make_mkv.update(make_mkv_params)
    redirect_to root_path
  end

  private

  def set_make_mkv
    @config_make_mkv = Config::MakeMkv.newest.first
  end

  def make_mkv_params
    params.require(:config_make_mkv).permit(settings: {})
  end
end
