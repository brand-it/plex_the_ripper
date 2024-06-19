# frozen_string_literal: true

class DisksController < ApplicationController
  def index
    @disks = Disk.all
  end

  def eject
    EjectDiskService.call(Disk.find(params[:id]))
    redirect_back_or_to :root
  end
end
