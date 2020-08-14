# frozen_string_literal: true

class Movie < ApplicationRecord
  include DiskWorkflow

  validates :title, presence: true
  validates :original_title, presence: true
end
