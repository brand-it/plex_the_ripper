# frozen_string_literal: true

module Rescuer
  extend ActiveSupport::Concern

  included do
    rescue_from Faraday::ConnectionFailed,
                with: :render_timeout_connection
    rescue_from TheMovieDb::Error,
                with: :render_movie_db_error
    rescue_from TheMovieDb::InvalidConfig,
                with: :movie_config_invalid

    rescue_from ActiveRecord::RecordNotFound,
                with: :not_found

    private

    def not_found(exception)
      flash[:error] = exception.message
      redirect_back_or_to root_path
    end

    def movie_config_invalid(exception)
      flash[:error] = exception.message
      redirect_to modify_config_the_movie_db_path
    end

    def render_movie_db_error(exception)
      @exception = exception
      render 'exceptions/movie_db_error', status: 522
    end

    def render_timeout_connection(exception)
      @exception = exception
      render 'exceptions/522', status: 522
    end
  end
end
