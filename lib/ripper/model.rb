# frozen_string_literal: true

module ModelMixin
  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def validate_presence(key)
      @validate_presence ||= []
      @validate_presence.push(key)
    end

    def columns(columns)
      @columns = columns
      columns.each do |name, type|
        define_method name do
          instance_variable_get("@#{name}")
        end
        define_method "#{name}=" do |value|
          value = self.class.cast_type(type, value)
          if column_presence_required?(name) && (value.nil? || value == '')
            raise(Model::Validation, "#{name} can't be blank for #{self.class.name}")
          end

          instance_variable_set("@#{name}", value)
        end
      end
    end

    def try_convert(value)
      return unless value.is_a?(self)

      value
    end

    def cast_type(type, value)
      case type.to_s
      when 'Integer'
        value&.to_i
      when 'String'
        value&.to_s
      when 'Array'
        type.try_convert(value) || type.new
      else
        type.try_convert(value)
      end
    end

    def inspect
      "#{super} #{@columns} #{@validate_presence}"
    end
  end
end

class Model
  class Validation < StandardError; end
  include ModelMixin

  def initialize(values = {})
    self.class.instance_variable_get('@columns').to_a.each do |key, _type|
      send("#{key}=", values[key] || values[key.to_s])
    end
  end

  def column_presence_required?(name)
    self.class.instance_variable_get('@validate_presence').to_a.include?(name)
  end
end
