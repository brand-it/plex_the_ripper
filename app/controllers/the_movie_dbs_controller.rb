# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  helper_method :search_service

  def index
    ScanPlexWorker.perform_async if search_service.results.empty?
  end

  def next_page
    respond_to do |format|
      format.turbo_stream { render layout: false }
      format.html { render :index }
    end
  end

  private

  def search_service
    @search_service ||= VideoSearchQuery.new(search_params)
  end

  def search_params
    params[:search]&.permit(:query, :page).to_h.symbolize_keys || {}
  end
end
