# frozen_string_literal: true

class Config
  class Serializer
    include SimplyEncrypt
    InspectKey = :__inspect_key__
    attr_reader :table # :nodoc:
    alias table! table
    protected :table!

    def initialize(hash = {})
      @table = {}
      hash.each do |k, v|
        @table[k.to_sym] = v
      end
    end

    def method_missing(mid, *args)
      len = args.length
      if (mname = mid[/.*(?==\z)/m])
        raise! ArgumentError, "wrong number of arguments (given #{len}, expected 1)", caller(1) if len != 1
        set_ostruct_member_value!(mname, args[0])
      elsif len.zero?
        @table[mid]
      else
        begin
          super
        rescue NoMethodError => e
          e.backtrace.shift
          raise!
        end
      end
    end

    def [](name)
      @table[name.to_sym]
    end

    def []=(name, value)
      @table[name.to_sym] = value
    end

    def dig(name, *names)
      begin
        name = name.to_sym
      rescue NoMethodError
        raise! TypeError, "#{name} is not a symbol nor a string"
      end
      @table.dig(name, *names)
    end

    #
    # Compares this object and +other+ for equality.  An Config::Serializer is equal to
    # +other+ when +other+ is an Config::Serializer and the two objects' Hash tables are
    # equal.
    #
    #   require "ostruct"
    #   first_pet  = Config::Serializer.new("name" => "Rowdy")
    #   second_pet = Config::Serializer.new(:name  => "Rowdy")
    #   third_pet  = Config::Serializer.new("name" => "Rowdy", :age => nil)
    #
    #   first_pet == second_pet   # => true
    #   first_pet == third_pet    # => false
    #
    def ==(other)
      return false unless other.is_a?(Config::Serializer)

      @table == other.table!
    end

    #
    # Compares this object and +other+ for equality. An Config::Serializer is eql? to
    # +other+ when +other+ is an Config::Serializer and the two objects' Hash tables are
    # eql?.
    #
    def eql?(other)
      return false unless other.is_a?(Config::Serializer)

      @table.eql?(other.table!)
    end

    def inspect
      ids = (Thread.current[InspectKey] ||= [])
      if ids.include?(object_id)
        detail = ' ...'
      else
        ids << object_id
        begin
          detail = @table.map do |key, value|
            " #{key}=#{value.inspect}"
          end.join(',')
        ensure
          ids.pop
        end
      end
      ['#<', class!, detail, '>'].join
    end
    alias to_s inspect

    def respond_to_missing?(method_name, include_private = false)
      method_name_str = method_name.to_s
      @table.key?(method_name) || @table.key?(method_name_str.chomp('=').to_sym) || super
    end

    def to_h
      @table.dup
    end

    def key?(name)
      @table.key?(name)
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
