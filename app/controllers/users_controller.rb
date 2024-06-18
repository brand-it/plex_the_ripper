# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.all
  end

  def show; end

  def new
    @user = User.new
  end

  def login
    user = User.find(params[:id])
    cookies[:user_id] = user.id
    flash[:notice] = "Logged in as #{user.name}"
    redirect_to users_path
  end

  def edit; end

  def create
    @user = User.new(user_params)

    if @user.save
      cookies[:user_id] = @user.id
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      cookies[:user_id] = @user.id
      redirect_to users_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to users_path, notice: 'User was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :time_zone)
  end
end
