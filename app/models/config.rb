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
  after_commit :clear_rails_cache
  class << self
    def setting(&block)
      return @setting unless block_given?

      @setting = Setting.call(block)
      @setting.attributes.each_key do |name|
        define_method("settings_#{name}") { settings[name] }
        define_method("settings_#{name}=") { |val| self.settings = { "#{name}": val } }
      end
    end

    def newest
      order(updated_at: :desc).first || new
    end
  end

  def settings
    self.class.setting.load(self, super)
  end

  def settings=(hash)
    super(self.class.setting.dump(self, settings.to_h.with_indifferent_access.merge(hash)))
  end

  def clear_rails_cache
    Rails.cache.delete(:"#{self.class.model_name.param_key}_newest")
  end
end
