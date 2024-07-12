# frozen_string_literal: true

class TvsController < ApplicationController
  def show
    @tv = if params[:id].start_with?('tmdb:')
            Tv.find_or_initialize_by(the_movie_db_id: params[:id].split(':').last)
          else
            Tv.find(params[:id])
          end
    @tv.subscribe(TheMovieDb::VideoListener.new)
    @tv.save!
  end
end
