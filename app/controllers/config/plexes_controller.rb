# frozen_string_literal: true

class Config::PlexesController < ApplicationController
  before_action :set_config_plex, only: %i[show edit update destroy]

  # GET /config/plexes
  # GET /config/plexes.json
  def index
    @config_plexes = Config::Plex.all
  end

  # GET /config/plexes/1
  # GET /config/plexes/1.json
  def show; end

  # GET /config/plexes/new
  def new
    @config_plex = Config::Plex.new
  end

  # GET /config/plexes/1/edit
  def edit; end

  # POST /config/plexes
  # POST /config/plexes.json
  def create
    @config_plex = Config::Plex.new(config_plex_params)

    respond_to do |format|
      if @config_plex.save
        format.html { redirect_to @config_plex, notice: 'Plex was successfully created.' }
        format.json { render :show, status: :created, location: @config_plex }
      else
        format.html { render :new }
        format.json { render json: @config_plex.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /config/plexes/1
  # PATCH/PUT /config/plexes/1.json
  def update
    respond_to do |format|
      if @config_plex.update(config_plex_params)
        format.html { redirect_to @config_plex, notice: 'Plex was successfully updated.' }
        format.json { render :show, status: :ok, location: @config_plex }
      else
        format.html { render :edit }
        format.json { render json: @config_plex.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /config/plexes/1
  # DELETE /config/plexes/1.json
  def destroy
    @config_plex.destroy
    respond_to do |format|
      format.html { redirect_to config_plexes_url, notice: 'Plex was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_config_plex
    @config_plex = Config::Plex.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def config_plex_params
    params.fetch(:config_plex, {})
  end
end
