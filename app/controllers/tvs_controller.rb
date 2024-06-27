# frozen_string_literal: true

class TvsController < ApplicationController
  def show
    @tv = Tv.find_video(params[:id]) || Tv.new(the_movie_db_id: params[:id])
    @tv.subscribe(TheMovieDb::TvListener.new)
    @tv.save!
  end
end
