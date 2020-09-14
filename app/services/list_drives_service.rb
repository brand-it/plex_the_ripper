# frozen_string_literal: true

class ListDrivesService
  extend Dry::Initializer
  include Shell
  include MkvParser

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: -> { Config::MakeMkv.current }
  option :noscan, Types::Bool, default: -> { false }

  def call
    drives.select { |d| d.enabled.to_i == 1 }
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
    @drives ||= parse_mkv_string(info.stdout_str).select { |i| i.is_a?(MkvParser::DRV) }
  end
end
