# frozen_string_literal: true

class MoviesController < ApplicationController
  def show
    LoadDiskWorker.perform
    @movie = Movie.find(params[:id])
    if @movie.new? # rubocop:disable Style/GuardClause
      @movie.select!
      @movie.save!
    end
  end
end
