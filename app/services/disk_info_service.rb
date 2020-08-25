# frozen_string_literal: true

class DiskInfoService
  extend Dry::Initializer
  include Shell
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
  }

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: proc { Config::MakeMkv.newest.first }
  option :drive, Types.Instance(ListDrivesService::Drive), default: proc { ListDrivesService.new.call }

  def call
    response = system!("#{config_make_mkv.settings.makemkvcon_path} info dev:#{drive.disk_name} -r")
    response.stdout_str.lines.each_with_object({}) do |line, hash|
      values = line.strip.split(',').map { |s| s.delete('"') }
      type, id = values.first.split(':')
      case type
      when 'TINFO'
        hash[id] ||= TitleInfo.new(id)
        puts values[1].to_i
        if attribute = CODE_LEGEND[values[1].to_i]
          hash[id].send("#{attribute}=", values.last)
        end
      end
    end.values
  end


  # def parse_disk_info_string(disk_info_string)
  #   lines = disk_info_string.split("\n")
  #   titles = {}
  #   lines.each do |line|
  #     match = line.delete('"').match(/(\A.*?):(.*)/)
  #     values = match[2].split(',')
  #     case match[1]
  #     when 'SINFO', 'TINFO'
  #       titles[values[0].to_i] ||= []
  #       titles[values[0].to_i].push(
  #         Detail.new(
  #           values[0].to_i,
  #           values[1].to_i,
  #           values[2].to_i,
  #           values[3].to_s.delete('"').delete('\\')
  #         )
  #       )
  #     end
  #   end
  #   if titles.size.zero?
  #     Logger.error(disk_info_string.gsub!('  ', ''))
  #     Logger.warning('No disk information found')
  #   end
  #   titles
  # end
end
