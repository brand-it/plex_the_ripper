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
  class << self
    def setting(&block)
      return @setting unless block_given?

      @setting = Setting.call(block)
      @setting.attributes.each do |name, _option|
        define_method("settings_#{name}") { settings[name] }
        define_method("settings_#{name}=") { |val| self.settings = { "#{name}": val } }
      end
    end

    def newest
      Rails.cache.fetch(:"#{model_name.param_key}_newest", expires_in: 2.seconds, skip_nil: true) do
        order(updated_at: :desc).first
      end || new
    end
  end

  def settings
    self.class.setting.load(self, super)
  end

  def settings=(hash)
    super(self.class.setting.dump(self, settings.to_h.with_indifferent_access.merge(hash)))
  end
end
