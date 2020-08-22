# frozen_string_literal: true

class TvsController < ApplicationController
  def show
    @tv = Tv.find(params[:id])
  end

  def create
    @tv = Tv.find_or_initialize_by(tv_params)
    @tv.subscribe(TheMovieDbTvListener.new) if @tv.the_movie_db_id

    if @tv.save
      flash[:success] = 'TV was created successfully created'
      redirect_to tv_path(@tv)
    else
      render :new
    end
  end

  private

  def tv_params
    params.require(:tv).permit(:the_movie_db_id, :name, :original_name)
  end
end
