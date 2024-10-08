# frozen_string_literal: true

module MkvParser
  TINFO_CODE_LEGEND = {
    2 => :name,
    8 => :chapter_count,
    9 => :duration,
    10 => :size,
    11 => :bytes,
    15 => :angle,
    16 => :source_file_name,
    25 => :segment_count,
    26 => :segement_map,
    27 => :filename,
    28 => :lang,
    29 => :language,
    30 => :description
  }.freeze
  CINFO = Struct.new(:id, :type, :code, :value)
  TINFO = Struct.new(:id, :type, :code, :value) do
    def id
      self[:id].to_i
    end

    def value
      case type
      when :description
        self[:value].is_a?(Array) ? self[:value].map(&:strip).join(', ') : self[:value]
      when :bytes, :angle, :chapter_count, :segment_count
        self[:value]&.to_i
      else
        self[:value].is_a?(Array) ? self[:value].join(',') : self[:value]
      end
    end

    def type
      TINFO_CODE_LEGEND[self[:type].to_i] || self[:type].to_i
    end
  end
  SINFO = Struct.new(:id, :type, :code, :value)
  TCOUNT = Struct.new(:title_count)
  # 0,2,999,12,"BD-ROM MATSHITA BD-CMB UJ141EL 1.10","Eureka D9","/dev/rdisk2"
  DRV = Struct.new(:index, :visible, :unknown, :enabled, :flags, :drive_name, :disc_name)
  # Progress bar values for current and total progress
  # PRGV:current,total,max
  # current - current progress value # maybe
  # total - total progress value # who know I think the docs are wrong
  # max - maximum possible value for a progress bar, constant
  PRGV = Struct.new(:current, :total, :pmax) do
    def pmax
      self[:pmax].presence.to_f
    end

    def current
      self[:current].presence.to_f
    end

    def total
      self[:total].presence.to_f
    end
  end
  # Current and total progress title
  # PRGC:code,id,name
  # PRGT:code,id,name
  # code - unique message code
  # id - operation sub-id
  # name - name string
  PRGT = Struct.new(:code, :id, :name)
  PRGC = Struct.new(:code, :id, :name)

  MSG = Struct.new(:code, :flags, :mcount, :message, :format, :params)
  Error = Struct.new(:type, :line, keyword_init: true)

  def parse_mkv_string(stdout_str)
    return [] if stdout_str.blank?

    stdout_str.lines.map do |line|
      line = line.strip.split(',').map { |s| s.delete('"\\') }
      type, id = line.shift.split(':')
      define_type(type, [id.to_i] + line) # ID is not really and ID but many things just ID was the best name
    end
  end

  def define_type(type, line)
    type = "MkvParser::#{type}".constantize
    if line.size <= type.new.members.size
      type.new(*line)
    else
      type.new(*line[0..(type.new.members.size - 2)], line[(type.new.members.size - 1)..])
    end
  rescue NameError => e
    Rails.logger.debug { "NameError message: #{e.message} type: #{type} line: #{line}" }
    Error.new(type:, line:)
  end
end
