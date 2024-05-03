# frozen_string_literal: true

class DiskTitlesController < ApplicationController
  def show
    @rip_worker = Job.find_by(name: 'RipWorker')
  end

  def update
    video = Video.find(params[:video_id])
    video.update!(disk_title_id: params[:id])
    disk_title = DiskTitle.find(params[:id])

    RipWorker.perform_async(disk_title_ids: [disk_title.id])
    redirect_to video_disk_title_path(video, disk_title)
  end
end
