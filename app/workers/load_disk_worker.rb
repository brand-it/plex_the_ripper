# frozen_string_literal: true

class LoadDiskWorker < ApplicationWorker
  def perform
    CreateDisksService.call
  end
end
