class Config
  class Setting
    include SimplyEncrypt

    Option = Struct.new(:default, :encrypted?)

    class << self
      def call(block)
        new.tap(&block)
      end
    end

    def load(json)
      load_attributes(Serializer.load(json))
    end

    def dump(object)
      JSON.dump dump_attributes(object).to_h
    end

    def attribute(name, default: -> {}, encrypted: false)
      attributes[name.to_sym] = Option.new(default, encrypted)
    end

    def attributes
      @attributes ||= {}
    end

    private

    def load_attributes(object)
      attributes.each do |name, option|
        object[name] = decrypt(object[name], object["#{name}_vi".to_sym]) if option.encrypted?
        object[name] = option.default.call unless contains_key?(object, name)
      end
      object
    end

    def dump_attributes(object)
      attributes.each do |name, option|
        object[name] = option.default.call unless contains_key?(object, name)
        object[name], object["#{name}_vi".to_sym] = encrypt(object[name]) if option.encrypted?
      end
      object
    end

    def contains_key?(object, key)
      (object.try(:marshal_dump) || object).key?(key)
    end
  end
end
