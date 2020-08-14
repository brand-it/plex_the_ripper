# frozen_string_literal: true

class Tv < ApplicationRecord
  include DiskWorkflow
  has_many :seasons
end
