# frozen_string_literal: true

class Config
  class MakeMkvsController < ApplicationController
    before_action :set_make_mkv, only: %i[edit update]

    def new
      @config_make_mkv = Config::MakeMkv.new
    end

    def create
      @config_make_mkv = Config::MakeMkv.new(make_mkv_params)

      if @config_make_mkv.save
        redirect_to root_path, notice: 'Make MKV Config was successfully created.'
      else
        render :new
      end
    end

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
end
