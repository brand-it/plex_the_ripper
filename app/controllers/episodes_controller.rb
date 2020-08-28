# frozen_string_literal: true

class EpisodesController < ApplicationController
  def show
    @season = Season.find(params[:id])
  end

  def select
    raise 'not implemented'
  end

  private

  def season_params
    params.require(:season).permit(:the_movie_db_id)
  end
end
