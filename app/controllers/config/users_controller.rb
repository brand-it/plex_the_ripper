# frozen_string_literal: true

class Config::UsersController < ApplicationController
  before_action :set_config_user, only: %i[show edit update destroy]

  # GET /config/users
  # GET /config/users.json
  def index
    @config_users = Config::User.all
  end

  # GET /config/users/1
  # GET /config/users/1.json
  def show; end

  # GET /config/users/new
  def new
    @config_user = Config::User.new
  end

  # GET /config/users/1/edit
  def edit; end

  # POST /config/users
  # POST /config/users.json
  def create
    @config_user = Config::User.new(config_user_params)

    respond_to do |format|
      if @config_user.save
        format.html { redirect_to @config_user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @config_user }
      else
        format.html { render :new }
        format.json { render json: @config_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /config/users/1
  # PATCH/PUT /config/users/1.json
  def update
    respond_to do |format|
      if @config_user.update(config_user_params)
        format.html { redirect_to @config_user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @config_user }
      else
        format.html { render :edit }
        format.json { render json: @config_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /config/users/1
  # DELETE /config/users/1.json
  def destroy
    @config_user.destroy
    respond_to do |format|
      format.html { redirect_to config_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_config_user
    @config_user = Config::User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def config_user_params
    params.fetch(:config_user, {})
  end
end
