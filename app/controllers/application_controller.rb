# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from 'Faraday::ConnectionFailed',
              with: :render_timeout_connection
  rescue_from 'TheMovieDb::Error',
              with: :render_movie_db_error
  rescue_from 'TheMovieDb::InvalidConfig',
              with: :movie_config_invalid

  def current_user
    return @current_user if defined? @current_user

    @current_user = User.find_by(id: cookies[:user_id])
  end

  private

  def render_timeout_connection(exception)
    raise exception unless Rails.env.production?

    @exception = exception
    render 'exceptions/522', status: 522
  end

  def render_movie_db_error(exception)
    # raise exception unless Rails.env.production?

    @exception = exception
    render 'exceptions/movie_db_error', status: 522
  end

  def movie_config_invalid(exception)
    flash[:error] = exception.message
    redirect_to_config_the_movie_db
  end

   def redirect_to_config_the_movie_db
    if movie_db_config.persisted?
      redirect_to edit_config_the_movie_db_path(movie_db_config)
    else
      redirect_to new_config_the_movie_db_path
    end
  end

  def redirect_to_config_plex
    if plex_config.persisted?
      redirect_to edit_config_plex
    else
      redirect_to new_config_plex_path
    end
  end

  def plex_config
    @plex_config ||= Config::Plex.newest.first || Config::Plex.new
  end

  def movie_db_config
    @movie_db_config ||= Config::TheMovieDb.newest.first || Config::TheMovieDb.new
  end
end
