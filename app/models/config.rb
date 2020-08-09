# frozen_string_literal: true

class Config < ApplicationRecord
  enum for: [:the_movie_db]
  serialize :settings, OpenStruct

  scope :newest, -> { order(updated_at: :desc) }
end
