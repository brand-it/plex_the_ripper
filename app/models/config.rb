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

  after_initialize :add_settings_defaults
  before_validation :add_settings_defaults

  class << self
    def settings_defaults
      @settings_defaults ||= {}
    end

    def setting(name, default: -> {})
      settings_defaults[name] = default
      define_method("settings_#{name}") { settings[name] }
      define_method("settings_#{name}=") { |val| settings[name] = val }
    end
  end

  private

  def add_settings_defaults
    self.class.settings_defaults.each do |name, default|
      next if settings.marshal_dump.key?(name)

      settings[name] = instance_exec(&default)
    end
  end
end
