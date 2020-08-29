# frozen_string_literal: true

class Disk < ApplicationRecord
  def load_disk_info
    @load_disk_info ||= ListDrivesService.new.call
  end
end
