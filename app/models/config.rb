# frozen_string_literal: true

class Config < ApplicationRecord
  SETTINGS_DEFAULTS = {}.freeze
  serialize :settings, OpenStruct

  scope :newest, -> { order(updated_at: :desc) }

  after_initialize :settings_defaults

  private

  def settings_defaults
    self.settings = OpenStruct.new(self.class::SETTINGS_DEFAULTS)
  rescue NameError => e
    raise "#{e.message} for #{self.class}"
  end
end
