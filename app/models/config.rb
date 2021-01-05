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
  class << self
    def settings(values)
      define_singleton_method(:settings) { Config::SettingSerializer.new(values) }
      values.each_key do |key|
        define_method("settings_#{key}") { settings.send(key) }
        define_method("settings_#{key}=") { |val| settings.send("#{key}=", val) }
      end
    end
  end

  def settings
    self.class.settings.merge(super)
  end
end
