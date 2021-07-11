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
  class << self
    def setting(&block)
      return @setting unless block_given?

      @setting = Setting.call(block)
      @setting.attributes.each do |name, _option|
        define_method("settings_#{name}") { settings[name] }
      end
    end
  end

  def settings
    self.class.setting.load(super)
  end

  def settings=(hash)
    super(self.class.setting.dump(settings.to_h.merge(hash)))
  end
end
