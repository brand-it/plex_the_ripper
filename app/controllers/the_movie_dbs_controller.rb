# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  helper_method :search_service

  def index; end

  def next_page
    respond_to do |format|
      format.turbo_stream { render layout: false }
      format.html { render :index }
    end
  end

  private

  def synced_recently?
    last_sync = Video.maximum(:synced_on)
    return false if last_sync.nil?

    last_sync + 5.minutes > Time.zone.now
  end

  def search_service
    @search_service ||= VideoSearchQuery.new(**search_params)
  end

  def search_params
    params[:search]&.permit(:query, :page).to_h.symbolize_keys || {}
  end
end
