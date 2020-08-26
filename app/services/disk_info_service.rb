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
      seconds + (minutes * 60) + (hours * 60 * 60)
    end
  end

  CODE_LEGEND = {
    9 => :duration,
    10 => :size,
    27 => :file_name
  }.freeze

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: proc { Config::MakeMkv.newest.first }
  option :drive, Types.Instance(MkvParser::DRV), default: proc { ListDrivesService.new.call }

  def call
    tinfo = parse_mkv_string(response.stdout_str).select { |line| line.is_a?(MkvParser::TINFO) }
    tinfo.each do |info|
    end
  end

  def info
    @info ||= system!(
      "#{config_make_mkv.settings.makemkvcon_path} info dev:#{drive.disk_name} -r"
    )
  end

  def find_or_init_title_info(id)
    title_info[id] ||= TitleInfo.new(id)
    attribute = CODE_LEGEND[values[1].to_i]
    return if attribute.nil?

    title_info[id].send("#{attribute}=", values.last)
  end

  def title_info
    @title_info ||= {}
  end
end
