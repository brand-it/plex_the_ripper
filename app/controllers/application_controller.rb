# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from 'Faraday::ConnectionFailed',
              with: :render_timeout_connection
  rescue_from 'TheMovieDb::Error',
              with: :render_movie_db_error

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
end
