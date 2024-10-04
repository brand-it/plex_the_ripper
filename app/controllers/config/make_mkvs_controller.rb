# frozen_string_literal: true

class Config
  class MakeMkvsController < ApplicationController
    before_action :set_make_mkv, only: %i[edit update]

    def new
      @config_make_mkv = Config::MakeMkv.new
    end

    def edit; end

    def create
      @config_make_mkv = Config::MakeMkv.new(make_mkv_params)

      if @config_make_mkv.save
        redirect_to root_path, success: 'Make MKV Config was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @config_make_mkv.update(make_mkv_params)
        flash[:success] = 'Updated Make MKV'
        redirect_to root_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def install
      if OS.mac?
        MkvInstaller::MacOs.call
      elsif OS.posix?
        MkvInstaller::Posix.call
      end

      redirect_to modify_config_make_mkv_path, notice: 'Make MKV has been installed'
    end

    private

    def set_make_mkv
      @config_make_mkv = Config::MakeMkv.newest
    end

    def make_mkv_params
      params.require(:config_make_mkv).permit(:settings_makemkvcon_path, :settings_registration_key)
    end
  end
end
