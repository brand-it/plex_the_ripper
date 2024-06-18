# frozen_string_literal: true

class DiskTitlesController < ApplicationController
  def update
    video = Video.find(params[:video_id])
    video.update!(disk_title_id: params[:id])
    disk_title = DiskTitle.find(params[:id])

    job = RipWorker.perform_async(disk_title_ids: [disk_title.id])
    redirect_to job_path(job)
  end
end
