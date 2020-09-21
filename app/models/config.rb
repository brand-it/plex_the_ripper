# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  settings   :text
#  type       :string           default("Config"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Config < ApplicationRecord
  scope :newest, -> { order(updated_at: :desc) }
  serialize :settings, Config::SettingSerializer

  def self.settings_defaults(values)
    define_singleton_method(:defaults) { Config::SettingSerializer.new(values) }
  end

  def settings
    self.class.defaults.merge(super)
  end
end
