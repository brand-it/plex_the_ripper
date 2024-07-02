# frozen_string_literal: true

class SystemsController < ApplicationController
  # Send a RESTART_SIGNAL to the current process
  # so it can shut down and restart. Only works with
  # bin/start
  def restart
    # Send SIGHUP (hangup signal) to the current process
    Thread.new do
      sleep 1 # give the server time to redirect to homepage
      Process.kill('HUP', Process.pid)
    end

    redirect_to wait_system_path
  end

  def wait
    render layout: 'minimal'
  end

  def health
    render json: { env: Rails.env }
  end
end
