# frozen_string_literal: true

class Config::TheMovieDbsController < ApplicationController
  before_action :set_the_movie_db, only: %i[show edit update destroy]

  def new
    @config_the_movie_db = Config::TheMovieDb.new
  end

  def edit; end

  def create
    @config_the_movie_db = Config::TheMovieDb.new(the_movie_db_params)

    @config_the_movie_db.save
    redirect_to root_path
  end

  def update
    @config_the_movie_db.update(the_movie_db_params)
    redirect_to root_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_the_movie_db
    @config_the_movie_db = Config::TheMovieDb.find(params[:id])
  end

  def user
    @newest_or_init ||= Config::TheMovieDb.newest.first || Config::TheMovieDb.new
  end

  # Only allow a list of trusted parameters through.
  def the_movie_db_params
    params.require(:config_the_movie_db).permit(settings: {})
  end
end
