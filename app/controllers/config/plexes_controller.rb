# frozen_string_literal: true

class Config::PlexesController < ApplicationController
  before_action :set_config_plex, only: %i[show edit update destroy]

  # GET /config/plexes
  # def index
  #   @config_plexes = Config::Plex.all
  # end

  # GET /config/plexes/new
  def new
    @config_plex = Config::Plex.new
  end

  # GET /config/plexes/1/edit
  def edit; end

  # POST /config/plexes
  def create
    @config_plex = Config::Plex.new(config_plex_params)

    if @config_plex.save
      redirect_to root_path, notice: 'Plex was successfully created.'
    else
      render :new
    end
  end

  def update
    if @config_plex.update(config_plex_params)
      redirect_to
      , notice: 'Plex was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /config/plexes/1
  # DELETE /config/plexes/1.json
  # def destroy
  #   @config_plex.destroy
  #   respond_to do |format|
  #     format.html { redirect_to config_plexes_url, notice: 'Plex was successfully destroyed.' }
  #   end
  # end

  def directories
    dir_path = params.fetch(:directory, Dir.home)
    entities = Dir.entries(dir_path)
    entities = entities.map { |e| File.join(dir_path, e) }.select { |e| File.directory?(e) }
    respond_to do |format|
      format.json { render json: entities }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_config_plex
    @config_plex = Config::Plex.newest.first
  end

  # Only allow a list of trusted parameters through.
  def config_plex_params
    params.require(:config_plex).permit(settings: [:movie_path, :video_path, :ftp_username, :ftp_host, :ftp_password])
  end
end
