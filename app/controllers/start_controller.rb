# frozen_string_literal: true

class StartController < ApplicationController
  def new
    if !mkv_config&.valid?
      redirect_to modify_config_make_mkv_path
    elsif !movie_db_config&.valid?
      redirect_to modify_config_the_movie_db_path
    elsif !plex_config&.valid?
      redirect_to modify_config_plex_path
    else
      redirect_to the_movie_dbs_path
    end
  end
end
