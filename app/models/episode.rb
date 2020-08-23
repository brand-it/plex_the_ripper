# frozen_string_literal: true

class Episode < ApplicationRecord
  include DiskWorkflow
  belongs_to :season
end
