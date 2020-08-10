# frozen_string_literal: true

class Config
  class SettingSerializer < OpenStruct
    def self.load(object)
      return new(@defaults) if object.blank?

      JSON.parse(object, object_class: self)
    end

    def self.dump(object)
      JSON.dump(@defaults.merge(object.to_h))
    end

    def merge(object)
      self.class.new(to_h.merge(object.to_h))
    end
  end
end
