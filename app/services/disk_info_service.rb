# frozen_string_literal: true

class DiskInfoService
  extend Dry::Initializer
  include Shell
  include MkvParser

  class TitleInfo
    extend Dry::Initializer
    attr_writer :duration, :size, :file_name

    param :id, Types::Coercible::Integer
    option :duration, Types::Coercible::String, optional: true
    option :size, Types::Coercible::String, optional: true
    option :file_name, Types::Coercible::String, optional: true

    def duration_seconds
      hours, minutes, seconds = duration.split(':')
      seconds.to_i + (minutes.to_i * 60) + (hours.to_i * 60 * 60)
    end
  end

  CODE_LEGEND = {
    9 => :duration,
    10 => :size,
    27 => :file_name
  }.freeze

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: proc { Config::MakeMkv.newest.first }
  option :disk_name, Types::String

  def results
    tinfos.each do |tinfo|
      find_or_init_title_info(tinfo)
    end
    title_info.values
  end

  def info
    @info ||= system!(
      "#{config_make_mkv.settings.makemkvcon_path} info dev:#{disk_name} -r"
    )
  end

  def tinfos
    @tinfos ||= parse_mkv_string(info.stdout_str).select { |line| line.is_a?(MkvParser::TINFO) }
  end

  def find_or_init_title_info(tinfo)
    title_info[tinfo.id.to_i] ||= TitleInfo.new(tinfo.id)
    attribute = CODE_LEGEND[tinfo.type.to_i]
    return if attribute.nil?

    title_info[tinfo.id.to_i].send("#{attribute}=", tinfo.value)
  end

  def title_info
    @title_info ||= {}
  end
end
