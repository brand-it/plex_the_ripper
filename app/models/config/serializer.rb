# frozen_string_literal: true

class Config
  class Serializer
    include SimplyEncrypt

    def initialize(hash = {})
      @table = {}
      hash.each do |k, v|
        @table[k.to_sym] = v
      end
    end

    def method_missing(method_name, *args, &block)
      method_name_str = method_name.to_s
      if method_name_str.end_with?('=')
        # Setter method
        @table[method_name_str.chomp('=').to_sym] = args.first
      elsif @table.key?(method_name)
        # Getter method
        @table[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name_str = method_name.to_s
      @table.key?(method_name) || @table.key?(method_name_str.chomp('=').to_sym) || super
    end

    def to_h
      @table.dup
    end

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
