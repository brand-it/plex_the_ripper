# frozen_string_literal: true

class DiskTitlesController < ApplicationController
  def show
    @rip_worker = ApplicationWorker.find('RipWorker')&.worker
  end

  def update
    disk_title = DiskTitle.find(params[:id])
    RipWorker.perform(disk_title_ids: [disk_title.id])
    redirect_to disk_title
  end
end
