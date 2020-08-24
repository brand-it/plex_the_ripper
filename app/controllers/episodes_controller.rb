# frozen_string_literal: true

class EpisodesController < ApplicationController
  def show
    @season = Season.find(params[:id])
  end

  def update
    @season = Episode.find(params[:id])

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
