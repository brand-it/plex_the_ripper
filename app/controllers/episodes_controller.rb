# frozen_string_literal: true

class EpisodesController < ApplicationController
  def show
    @season = Season.find(params[:id])
  end

  def select
    drive = ListDrivesService.new.call
    Disk.create!(name: drive.name)
    if drive
      disk_info = DiskInfoService.new(drive: drive).call
      binding.pry
      episodes.each(&:select!)
    end
  end

  private

  def season_params
    params.require(:season).permit(:the_movie_db_id)
  end

  def episodes
    Episode.where(id: params.dig(:episodes, :selected, :id))
  end

  def tv
    @tv ||= episodes.first.season.tv
  end
end
