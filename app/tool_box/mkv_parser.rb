# frozen_string_literal: true

module MkvParser
  CINFO = Struct.new(:id, :code, :value)
  TINFO = Struct.new(:id, :code, :value)
  SINFO = Struct.new(:id, :code, :value)
  TCOUNT = Struct.new(:count)
  DRV = Struct.new(:index, :visible, :unknown, :enabled, :flags, :drive_name, :disc_name)
  PRGV = Struct.new(:current, :total, :max)
  PRGT = Struct.new(:code, :id, :name)
  PRGC = Struct.new(:code, :id, :name)
  MSG = Struct.new(:code, :flags, :count, :message, :format, :params)

  def parse_mkv_string(stdout_str) # rubocop:disable Metrics/AbcSize
    return [] if stdout_str.blank?

    stdout_str.lines.map do |line|
      type, line = line.split(':')
      line = line.strip.split(',').map { |s| s.delete('"\\') }
      type = "MkvParser::#{type}".constantize
      if type.new.members.size <= line.size
        type.new(*line)
      else
        type.new(*line[0..(type.new.members.size - 1)], line[type.new.members.size..])
      end
    end
  end
end
