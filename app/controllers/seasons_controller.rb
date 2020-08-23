class SeasonsController < ApplicationController
  def show
    @season = Season.find(params[:id])
  end

  def create
    @season = Season.find_or_initialize_by(season_params)
    @season.subscribe(TheMovieDbSeasonListener.new)

    if @season.save
      flash[:success] = 'Season was created successfully created'
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
