# frozen_string_literal: true

class Config
  class TheMovieDbsController < ApplicationController
    before_action :set_the_movie_db, only: %i[edit update]

    def new
      @config_the_movie_db = Config::TheMovieDb.new
    end

    def edit; end

    def create
      @config_the_movie_db = Config::TheMovieDb.new(the_movie_db_params)

      flash[:success] = 'Created Movie DB API key' if @config_the_movie_db.save
      redirect_to root_path
    end

    def update
      if @config_the_movie_db.update(the_movie_db_params) && @config_the_movie_db.save
        flash[:success] = 'Updated Movie DB API key'
      end
      redirect_to root_path
    end

    private

    def set_the_movie_db
      @config_the_movie_db = Config::TheMovieDb.newest
    end

    def the_movie_db_params
      params.require(:config_the_movie_db).permit(settings: {})
    end
  end
end
