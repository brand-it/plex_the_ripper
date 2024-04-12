# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  helper_method :search_service

  def index
    return unless (Video.none? || !synced_recently?) && !ScanPlexWorker.job.pending?

    ScanPlexWorker.perform_async
  end

  def next_page
    respond_to do |format|
      format.turbo_stream { render layout: false }
      format.html { render :index }
    end
  end

  private

  def synced_recently?
    Video.maximum(:synced_on) < 5.minutes.ago
  end

  def search_service
    @search_service ||= VideoSearchQuery.new(**search_params)
  end

  def search_params
    params[:search]&.permit(:query, :page).to_h.symbolize_keys || {}
  end
end
