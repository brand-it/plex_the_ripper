# frozen_string_literal: true

class StartController < ApplicationController
  def new
    if movie_db_config.nil? || movie_db_config.settings_invalid?
      redirect_to modify_config_the_movie_db_path
    elsif plex_config.nil? || plex_config.settings_invalid?
      redirect_to modify_config_plex_path
    else
      redirect_to the_movie_dbs_path
    end
  end
end
