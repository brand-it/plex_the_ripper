# frozen_string_literal: true

class Config
  class Setting
    include SimplyEncrypt

    Option = Struct.new(:default, :encrypted?)

    class << self
      def call(block)
        new.tap(&block)
      end
    end

    def load(item, json)
      load_attributes(item, Serializer.load(json))
    end

    def dump(item, object)
      JSON.dump dump_attributes(item, object).to_h
    end

    def attribute(name, default: -> {}, encrypted: false)
      attributes[name.to_sym] = Option.new(default, encrypted)
    end

    def attributes
      @attributes ||= {}
    end

    private

    def load_attributes(item, object)
      attributes.each do |name, option|
        object[name] = decrypt(object[name], object["#{name}_vi".to_sym]) if option.encrypted?
        object[name] = instance_exec_default(item, option) unless contains_key?(object, name)
      end
      object
    end

    def dump_attributes(item, object)
      attributes.each do |name, option|
        object[name] = instance_exec_default(item, option) unless contains_key?(object, name)
        object[name], object["#{name}_vi".to_sym] = encrypt(object[name]) if option.encrypted?
      end
      object
    end

    def instance_exec_default(item, option)
      item.instance_exec(&option.default)
    end

    def contains_key?(object, key)
      (object.try(:marshal_dump) || object).key?(key)
    end
  end
end
