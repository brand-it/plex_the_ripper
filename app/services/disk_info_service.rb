# frozen_string_literal: true

class DiskInfoService < ApplicationService
  include Shell

  class TitleInfo
    extend Dry::Initializer
    attr_accessor(*MkvParser::TINFO_CODE_LEGEND.values)

    param :id, Types::Coercible::Integer

    def duration_seconds
      hours, minutes, seconds = duration.split(':')
      seconds.to_i + (minutes.to_i * 60) + (hours.to_i * 60 * 60)
    end
  end

  option :disk_name, Types::String

  def call
    tinfos.each do |tinfo|
      find_or_init_title_info(tinfo)
    end
    title_info.values
  end

  private

  def info
    @info ||= wait_makemkvcon("info dev:#{disk_name} -r")
  end

  def tinfos
    @tinfos ||= parse_mkv_string(info.stdout_str).select { |line| line.is_a?(MkvParser::TINFO) }
  end

  def find_or_init_title_info(tinfo)
    title_info[tinfo.id] ||= TitleInfo.new(tinfo.id)
    return if tinfo.type.nil? || tinfo.type.is_a?(Integer)

    title_info[tinfo.id].public_send("#{tinfo.type}=", tinfo.value)
  end

  def title_info
    @title_info ||= {}
  end
end
