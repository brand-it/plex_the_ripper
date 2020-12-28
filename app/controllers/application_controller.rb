# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # include Rescuer

  before_action :plex_config
  before_action :movie_db_config
  before_action :mkv_config
  before_action :load_disk

  def current_user
    return @current_user if defined? @current_user

    @current_user = User.find_by(id: cookies[:user_id])
  end

  private

  def load_disk
    LoadDiskWorker.perform unless Disk.all_valid?
  end

  def modify_config_the_movie_db_path
    movie_db_config ? edit_config_the_movie_db_path : new_config_the_movie_db_path
  end
  helper_method :modify_config_the_movie_db_path

  def modify_config_plex_path
    plex_config ? edit_config_plex_path : new_config_plex_path
  end
  helper_method :modify_config_plex_path

  def modify_config_make_mkv_path
    edit_config_make_mkv_path
  end
  helper_method :modify_config_make_mkv_path

  def plex_config
    return @plex_config if defined? @plex_config

    @plex_config ||= Config::Plex.newest.first
  end

  def movie_db_config
    return @movie_db_config if defined? @movie_db_config

    @movie_db_config ||= Config::TheMovieDb.newest.first
  end

  def mkv_config
    @mkv_config ||= Config::MakeMkv.newest.first || Config::MakeMkv.create
  end
end
