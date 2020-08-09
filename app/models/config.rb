# frozen_string_literal: true

class Config < ApplicationRecord
  enum for: %i[the_movie_db user]
  serialize :settings, OpenStruct

  scope :newest, -> { order(updated_at: :desc) }

  after_initialize :user_defaults, if: :user?

  private

  def user_defaults
    settings.dark_mode = true
  end
end
