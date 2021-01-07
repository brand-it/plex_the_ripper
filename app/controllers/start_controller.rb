# frozen_string_literal: true

class StartController < ApplicationController
  def new
    redirect_to_config_make_mkv ||
      redirect_to_config_the_movie_db ||
      redirect_to_config_plex ||
      redirect_to(the_movie_dbs_path)
  end

  private

  def redirect_to_config_make_mkv
    return if mkv_config&.valid?

    redirect_to modify_config_make_mkv_path
  end

  def redirect_to_config_the_movie_db
    return if movie_db_config&.valid?

    redirect_to modify_config_the_movie_db_path
  end

  def redirect_to_config_plex
    return if plex_config&.valid?

    redirect_to modify_config_plex_path
  end
end
