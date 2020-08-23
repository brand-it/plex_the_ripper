# frozen_string_literal: true

class SeasonsController < ApplicationController
  def show
    @season = Season.find(params[:id])
  end

  def update
    @season = Season.find(params[:id])
    @season.subscribe(TheMovieDbSeasonListener.new)

    if @season.update(season_params)
      redirect_to season_path(@season)
    else
      render :new
    end
  end

  private

  def season_params
    params.require(:season).permit(:the_movie_db_id)
  end
end
