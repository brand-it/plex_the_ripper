# frozen_string_literal: true

class Config
  class Serializer < OpenStruct
    include SimplyEncrypt

    class << self
      def dump(object)
        JSON.dump object.to_h
      end

      def load(json)
        return new if json.blank?

        JSON.parse(json, object_class: self)
      end
    end
  end
end
