# frozen_string_literal: true

class ListDrivesService
  extend Dry::Initializer
  include Shell
  include MkvParser
  include Wisper::Publisher

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: -> { Config::MakeMkv.current }
  option :noscan, Types::Bool, default: -> { false }

  def results
    broadcast(:drives_loaded, drives)
    drives
  end

  private

  def makemkvcon_path
    config_make_mkv.settings.makemkvcon_path
  end

  def info
    @info ||= system!(
      [
        makemkvcon_path,
        '-r',
        '--cache=1',
        ('--noscan' if noscan),
        'info',
        'disc:9999'
      ].compact.join(' ')
    )
  end

  def drives
    @drives ||= parse_mkv_string(info.stdout_str).select do |i|
      i.is_a?(MkvParser::DRV) && d.enabled.to_i == 1
    end
  end
end
