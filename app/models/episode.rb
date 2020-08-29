# frozen_string_literal: true

class Episode < ApplicationRecord
  include DiskWorkflow
  belongs_to :season
  belongs_to :disk, optional: true
  belongs_to :disk_title, optional: true
end
