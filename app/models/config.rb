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
      key = :"#{model_name.param_key}_newest"
      key_time = :"#{key}_time"

      # Fetch the last cache timestamp and value
      last_cache_time = Thread.current.thread_variable_get(key_time) || Time.zone.at(0)
      cached_value = Thread.current.thread_variable_get(key)

      # Only re-fetch from the DB if the cache is older than 1 second
      if Time.zone.now - last_cache_time > 1 || cached_value.nil?
        cached_value = order(updated_at: :desc).first
        # Store the new cache value and update the cache timestamp
        Thread.current.thread_variable_set(key, cached_value)
        Thread.current.thread_variable_set(key_time, Time.zone.now)
      end

      cached_value || new
    end
  end

  def settings
    self.class.setting.load(self, super)
  end

  def settings=(hash)
    super(self.class.setting.dump(self, settings.to_h.with_indifferent_access.merge(hash)))
  end

  def clear_rails_cache
    Thread.current.thread_variable_set(:"#{self.class.model_name.param_key}_newest", nil)
  end
end
