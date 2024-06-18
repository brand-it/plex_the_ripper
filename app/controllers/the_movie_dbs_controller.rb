# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  helper_method :search_service

  def index; end

  def next_page
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream
    end
  end

  private

  def search_service
    @search_service ||= VideoSearchQuery.new(**search_params)
  end

  def search_params
    params[:search]&.permit(:query, :page).to_h.symbolize_keys || {}
  end
end
