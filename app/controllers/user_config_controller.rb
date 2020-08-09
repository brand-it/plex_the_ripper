# frozen_string_literal: true

class UserConfigController < ApplicationController

  def toggle_dark_mode
    @config = Config.find_or_initialize_by(for: :user)
    @config.settings.dark_mode = !@config.settings.dark_mode
    @config.save
  end
end
