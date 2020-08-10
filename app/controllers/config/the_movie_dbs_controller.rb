# frozen_string_literal: true

class Config::TheMovieDbsController < ApplicationController
  before_action :set_the_movie_db, only: %i[show edit update destroy]

  # GET /config/users
  # GET /config/users.json
  def index
    @config_the_movie_dbs = Config::TheMovieDb.all.page params[:page]
  end

  # GET /config/users/1
  # GET /config/users/1.json
  def show; end

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

    respond_to do |format|
      if @config_the_movie_db.save
        format.html { redirect_to @config_the_movie_db, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @config_the_movie_db }
      else
        format.html { render :new }
        format.json { render json: @config_the_movie_db.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /config/users/1
  # PATCH/PUT /config/users/1.json
  def update
    respond_to do |format|
      if @config_the_movie_db.update(the_movie_db_params)
        format.html { redirect_to @config_the_movie_db, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @config_the_movie_db }
      else
        format.html { render :edit }
        format.json { render json: @config_the_movie_db.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /config/users/1
  # DELETE /config/users/1.json
  def destroy
    @config_the_movie_db.destroy
    respond_to do |format|
      format.html { redirect_to the_movie_dbs_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
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
