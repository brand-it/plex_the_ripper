# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Rescuer

  before_action :mkv_config
  before_action :movie_db_config
  before_action :plex_config
  around_action :set_time_zone
  helper_method :free_disk_space, :total_disk_space

  def current_user
    return @current_user if defined? @current_user

    @current_user = User.find_by(id: cookies[:user_id])
  end
  helper_method :current_user

  def free_disk_space
    @free_disk_space ||= stats.block_size * stats.blocks_available
  end

  def total_disk_space
    @total_disk_space ||= stats.block_size * stats.blocks
  end

  private

  def stats
    @stats ||= Sys::Filesystem.stat('/')
  end

  def modify_config_the_movie_db_path
    movie_db_config.persisted? ? edit_config_the_movie_db_path : new_config_the_movie_db_path
  end
  helper_method :modify_config_the_movie_db_path

  def modify_config_plex_path
    plex_config.persisted? ? edit_config_plex_path : new_config_plex_path
  end
  helper_method :modify_config_plex_path

  def modify_config_make_mkv_path
    mkv_config.persisted? ? edit_config_make_mkv_path : new_config_make_mkv_path
  end
  helper_method :modify_config_make_mkv_path

  def plex_config
    return @plex_config if defined? @plex_config

    @plex_config = Config::Plex.newest
  end

  def movie_db_config
    return @movie_db_config if defined? @movie_db_config

    @movie_db_config = Config::TheMovieDb.newest
  end

  def mkv_config
    return @mkv_config if defined? @mkv_config

    @mkv_config = Config::MakeMkv.newest
  end

  def set_time_zone(&)
    timezone = current_user&.time_zone || Rails.configuration.time_zone
    Time.use_zone(timezone, &)
  end
end
