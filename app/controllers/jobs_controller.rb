# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    @jobs = Job.sort_by_created_at.active.or(Job.problem).limit(100)
  end

  def show
    @job = Job.find(params[:id])
    redirect_to jobs_path if @job.nil?
  end

  def load_disk; end
end
