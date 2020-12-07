# frozen_string_literal: true

module Rescuer
  extend ActiveSupport::Concern

  included do
    rescue_from 'Faraday::ConnectionFailed',
                with: :render_timeout_connection
    rescue_from 'TheMovieDb::Error',
                with: :render_movie_db_error
    rescue_from 'TheMovieDb::InvalidConfig',
                with: :movie_config_invalid
    rescue_from ActiveRecord::PendingMigrationError,
                with: :migrate_and_redirect

    private

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

    def migrate_and_redirect(exception)
      success = ActiveRecord::Tasks::DatabaseTasks.migrate
      binding.pry
      redirect_to
    end
  end
end
