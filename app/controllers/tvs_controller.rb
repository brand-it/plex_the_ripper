# frozen_string_literal: true

class TvsController < ApplicationController
  def show
    scope = Tv.includes(:seasons)
    @tv = if params[:id].start_with?('tmdb:')
            scope.find_or_initialize_by(the_movie_db_id: params[:id].split(':').last)
          else
            scope.find(params[:id])
          end
    @tv.subscribe(TheMovieDb::VideoListener.new)
    @tv.save!
  end
end
