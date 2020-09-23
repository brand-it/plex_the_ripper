# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    @jobs = ApplicationWorker.jobs
  end

  def show
    @job = ApplicationWorker.find(params[:id])
    redirect_to jobs_path if @job.nil?
  end
end
