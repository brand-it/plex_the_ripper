# frozen_string_literal: true

module MkvParser
  CINFO = Struct.new(:id, :type, :code, :value)
  TINFO = Struct.new(:id, :type, :code, :value)
  SINFO = Struct.new(:id, :type, :code, :value)
  TCOUNT = Struct.new(:count)
  DRV = Struct.new(:index, :visible, :unknown, :enabled, :flags, :drive_name, :disc_name)
  # Progress bar values for current and total progress
  # PRGV:current,total,max
  # current - current progress value
  # total - total progress value
  # max - maximum possible value for a progress bar, constant
  PRGV = Struct.new(:current, :total, :max)
  # Current and total progress title
  # PRGC:code,id,name
  # PRGT:code,id,name
  # code - unique message code
  # id - operation sub-id
  # name - name string
  PRGT = Struct.new(:code, :id, :name)
  PRGC = Struct.new(:code, :id, :name)

  MSG = Struct.new(:code, :flags, :count, :message, :format, :params)

  def parse_mkv_string(stdout_str)
    return [] if stdout_str.blank?

    stdout_str.lines.map do |line|
      line = line.strip.split(',').map { |s| s.delete('"\\') }
      type, id = line.shift.split(':')
      define_type(type, [id.to_i] + line) # ID is not really and ID but many things just ID was the best name
    end
  end

  def define_type(type, line) # rubocop:disable Metrics/AbcSize
    type = "MkvParser::#{type}".constantize
    if line.size <= type.new.members.size
      type.new(*line)
    else
      type.new(*line[0..(type.new.members.size - 2)], line[(type.new.members.size - 1)..])
    end
  rescue NameError => e
    Rails.logger.debug("NameError #{e.message} #{type} #{line}")
    OpenStruct.new(type: type, line: line)
  end
end
