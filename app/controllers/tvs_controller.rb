# frozen_string_literal: true

class TvsController < ApplicationController
  def show
    @tv = Tv.find_or_initialize_by(the_movie_db_id: params[:id])
    @tv.subscribe(TheMovieDb::VideoListener.new)
    @tv.save!
  end
end
