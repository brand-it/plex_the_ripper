# frozen_string_literal: true

class Config::TheMovieDbsController < ApplicationController
  before_action :set_the_movie_db, only: %i[show edit update destroy]

  # GET /config/users/new
  def new
    @config_the_movie_db = Config::TheMovieDb.new
  end

  # GET /config/users/1/edit
  def edit; end

  # POST /config/users
  # POST /config/users.json
  def create
    @config_the_movie_db = Config::TheMovieDb.new(the_movie_db_params)

    @config_the_movie_db.save
    render :new
  end

  def update
    @config_the_movie_db.update(the_movie_db_params)
    render :edit
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_the_movie_db
    @config_the_movie_db = Config::TheMovieDb.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def the_movie_db_params
    params.require(:config_the_movie_db).permit(settings: {})
  end
end
