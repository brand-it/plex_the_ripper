# frozen_string_literal: true

class Config
  class PlexesController < ApplicationController
    before_action :set_config_plex, only: %i[edit update]

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
        ScanPlexWorker.perform_async
        redirect_to root_path, notice: 'Plex was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @config_plex.update(config_plex_params)
        ScanPlexWorker.perform_async
        redirect_to root_path, notice: 'Plex was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def directories
      respond_to do |format|
        format.json do
          render json: directories_json
        end
      end
    end

    private

    def directories_json
      cache_key = Base64.encode64(params.to_s)
      Rails.cache.fetch(cache_key, namespace: 'plex_directories_json', expires_in: 1.minute) do
        response = Ftp::ListDir.search(**params.to_unsafe_h)
        {
          dirs: response.dirs, message: response.message, success: response.success?
        }
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_config_plex
      @config_plex = Config::Plex.newest
    end

    # Only allow a list of trusted parameters through.
    def config_plex_params
      params.require(:config_plex).permit(settings: %i[movie_path tv_path ftp_username ftp_host ftp_password])
    end
  end
end
